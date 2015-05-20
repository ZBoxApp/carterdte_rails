require 'multi_json'
require 'faraday'
require 'elasticsearch/api'
require 'hashie'
require 'json'

# Esta clase es la que busca cosas
class SearchMessage
  include Elasticsearch::API

  attr_accessor :index

  CONNECTION = ::Faraday::Connection.new url: "http://#{ENV['elasticsearch_host']}:9200"

  def initialize()
    @index = set_index_name
  end

  def dated_index(ds, de)
    # Queremos saber si estan en la misma decena
    # por ej: 2015-12-23 y 2015-12-29
    same_decena = (ds.day / 10) == (de.day / 10)

    # Devolvemos 2015.12.2* si estan en la misma decena
    return "#{ds.to_s.chop.gsub(/-/, '.')}*" if same_decena

    # Devolvemos 2015.12.* en otro caso
    "#{ds.to_s[0...-3].gsub(/-/, '.')}.*"
  end

  # TODO: Comprobar cuando son NIL
  def build_query(must, should, scope, s_date, e_date)
    index = set_index_name(s_date, e_date)
    q_hash = Hash.new { |h, k| h[k] = Hash.new(&h.default_proc) }
    q_hash[:filtered][:filter][:bool][:must] = must
    q_hash[:filtered][:filter][:bool][:should] = should unless should.nil?
    q_hash[:range]['@timestamp']['gte'] = s_date
    q_hash[:range]['@timestamp']['lte'] = e_date
    q_hash[:filtered][:filter][:bool][:must] << {'range' => q_hash[:range]}
    q_hash.delete(:range)
    { index: index, body: { sort: {"@timestamp" => "desc"}, query: q_hash } }
  end

  def from_amavisd_info(opts = {})
    must = to_term_filter('tags' => ['amavis', 'result'],
                           'from' => opts['from'],
                           'to' => opts['to']
                          )
    query = build_query(must, nil, nil, opts['start_date'], opts['end_date'])

    response = search query
    pp response
    hashie = Hashie::Mash.new JSON.parse response
    #hashie.hits.hits.map { |h| h._source.messageid }
  end

  def from_qmgr_info(opts = {})
    must = to_term_filter('component' => 'qmgr',
                           'queuestatus' => 'queue active',
                           'from' => opts['from']
                          )
    query = build_query(must, nil, nil, opts['start_date'], opts['end_date'])
    response = search query
    hashie = Hashie::Mash.new JSON.parse response
    #hashie.hits.hits.map { |h| h._source.qid }
  end

  def from_smtp_info(opts = {})
    must = to_term_filter('tags' => 'relay',
                           'to' => opts['to']
                          )
    query = build_query(must, nil, nil, opts['start_date'], opts['end_date'])
    hashie = Hashie::Mash.new JSON.parse response
    hashie.hits.hits.map { |h| h._source.qid }
  end

  def from_cleanup_info(opts = {})
    must = to_term_filter('component' => 'cleanup')
    qids_array = opts['qids'].map { |q| {'qid' => q}  }
    should = to_term_filter(qids_array)

    query = build_query(must, should, nil, opts['start_date'], opts['end_date'])
    response = search query
    hashie = Hashie::Mash.new JSON.parse response
    hashie.hits.hits.map { |h| h._source.messageid }.uniq
  end


  # This make the talk with ES
  def perform_request(method, path, params, body)
    CONNECTION.run_request \
      method.downcase.to_sym,
      path,
      ( body ? MultiJson.dump(body): nil ),
      {'Content-Type' => 'application/json'}
  end

  def set_index_name(ds = nil, de = nil)
    if ds.is_a?(Date) && de.is_a?(Date)
      date = dated_index(ds, de)
    else
      date = today_index
    end
    "logstash-#{date}"
  end

  # Nos permite pasar un hash de busqueda estilo
  # {'campo' => 'consulta', 'campo' => 'consulta'}, y devuelve un Array
  # [{ term: {'campo.raw' => 'consulta'}}]
  def to_term_filter(lookup)
    look_array = lookup if lookup.is_a? Array
    look_array = [lookup] if lookup.is_a? Hash
    result = []
    look_array.each do |lookup_hash|
      lookup_hash.each do |k, v|
        result << { 'term' => { "#{k}.raw" => v } }
      end
    end
    result
  end

  def today_index
    # Return something like logstash-2015.10.03
    Time.zone.now.to_date.to_s.gsub(/-/, '.')
  end

  def user_scope(user)
    return [] if user.admin?
    hash = { 'terms' => {} }
    hash['terms'] = { 'host.raw' => user.servers_name } if user.itlinux?
    hash['terms'] = { 'from_domain.raw' => user.domains_name,
                      'to_domain.raw' => user.domains_name } if user.zbox_mail?
    hash
  end

  # Opts has to have
  # :user, :index, :from, :to, :start_date, :end_date, dte:
  def where(opts = {})
    fail ArgumentError unless opts['from'] || opts['to']
    return dte_lookup(opts) if opts['dte']
    return from_amavisd_info(opts) if opts['from'] && opts['to']
    return from_qmgr_info(opts) if opts['from'] && !opts['to']
    return from_smtp_info(opts) if !opts['from'] && opts['to']
  end

  def self.build_index_name(name = nil)
    return Time.zone.today.to_s.gsub(/-/, '.') unless name
  end
end
