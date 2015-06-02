require 'multi_json'
require 'faraday'
require 'elasticsearch/api'
require 'hashie'
require 'json'

# Esta clase es la que busca cosas
class SearchLog
  include Elasticsearch::API

  attr_accessor :index, :from, :to, :jail, :query, :raw_query
  attr_reader :s_date, :e_date

  CONNECTION = ::Faraday::Connection.new url: "http://#{Figaro.env.elasticsearch_host}:9200"
  SEARCH_SIZE = 25

  def initialize(jail: nil, query: nil, s_date: nil, e_date: nil)
    @raw_query = to_term_filter(query)
    @jail = jail
    #set_dates(s_date, e_date)
    @s_date = s_date
    @e_date = e_date
    @index = set_index_name
    @query = build_query
  end

  def self.find(jail = nil, id = nil)
    query = { 'term' => { '_id'=> id } }
    s = SearchLog.new(jail: jail, query: query)
    # Sacamos la fecha para que busque x todos los registros
    # y tambien hacemos que el index sea 'logstash-*'
    s.query[:body][:query][:filtered][:filter][:bool][:must].delete_at(0)
    s.query[:body][:query][:filtered][:filter][:bool][:must] = query
    s.query[:index] = 'logstash-*'
    s.execute
  end

  def dated_index(ds, de)
    # Queremos saber si estan en la misma decena
    # por ej: 2015-12-23 y 2015-12-29
    return ds.to_s.gsub(/-/, '.') if ds == de
    same_decena = (ds.day / 10) == (de.day / 10)

    # Devolvemos 2015.12.2* si estan en la misma decena
    return "#{ds.to_s.chop.gsub(/-/, '.')}*" if same_decena

    # Devolvemos 2015.12.* en otro caso
    "#{ds.to_s[0...-3].gsub(/-/, '.')}.*"
  end

  def build_query
    index = set_index_name
    filtered = build_query_filter
    { index: index, body: { sort: { '@timestamp' => 'desc' }, query: filtered } }
  end

  def build_query_filter
    query_filter = buil_must_query_filter
    q_hash = Hash.new { |h, k| h[k] = Hash.new(&h.default_proc) }
    q_hash[:filtered][:filter][:bool][:must_not] = { :term=>{"tags.raw"=>"unknown"} }
    q_hash[:filtered][:filter][:bool][:must] = query_filter
    q_hash[:filtered][:filter][:bool][:should] = jail_filter
    q_hash
  end

  # Aqui es donde juntamos la query que ingresamos
  # con los otros datos
  def buil_must_query_filter
    query_filter = [{ 'range' => date_range_filter }]
    query_filter | @raw_query
  end

  def date_range_filter
    # Si ambas son nil, ajustamos la fecha para hoy
    q_hash = { '@timestamp' => {} }
    q_hash['@timestamp']['gte'] = @s_date unless @s_date.nil?
    q_hash['@timestamp']['lte'] = @e_date unless @e_date.nil?
    q_hash
  end

  def jail_filter
    return [] unless jail
    to_term_filter jail
  end

  # Este es el metodo hace la busqueda
  # From para paginacion, size es la cantidad total de resultados
  def execute(from = 0, size = SEARCH_SIZE)
    self.query[:body][:from] = from
    self.query[:body][:size] = size
    response = search(query)
    SearchLogResult.new(response, from, size, self)
  end

  # Este es un bridge al search original
  def self.raw_search(search_log_object)
    search_log_object.search search_log_object.query
  end

  # This make the talk with ES
  def perform_request(method, path, params, body)
    CONNECTION.run_request \
      method.downcase.to_sym,
      path,
      ( body ? MultiJson.dump(body): nil ),
      {'Content-Type' => 'application/json'}
  end

  def set_dates(ds = nil, de = nil)
    if ds.nil? || de.nil?
      date = Time.zone.now.to_date
      @e_date = date
      @s_date = date
    else
      @s_date = ds
      @e_date = de
    end
  end

  def set_index_name
    #date = dated_index(s_date, e_date)
    #"logstash-#{date}"
    'logstash-201*'
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
        result << { 'term' => { "#{k}.raw" => v } } unless v.nil?
      end
    end
    result
  end

  def today_index
    # Return something like logstash-2015.10.03
    Time.zone.now.to_date.to_s.gsub(/-/, '.')
  end
end

# def from_qmgr_info(opts = {})
#   must = to_term_filter('component' => 'qmgr',
#                          'queuestatus' => 'queue active',
#                          'from' => opts['from']
#                         )
#   query = build_query(must, nil, nil, opts['start_date'], opts['end_date'])
#   response = search query
#   hashie = Hashie::Mash.new JSON.parse response
#   #hashie.hits.hits.map { |h| h._source.qid }
# end
#
# def from_smtp_info(opts = {})
#   must = to_term_filter('tags' => 'relay',
#                          'to' => opts['to']
#                         )
#   query = build_query(must, nil, nil, opts['start_date'], opts['end_date'])
#   hashie = Hashie::Mash.new JSON.parse response
#   hashie.hits.hits.map { |h| h._source.qid }
# end
#
# def from_cleanup_info(opts = {})
#   must = to_term_filter('component' => 'cleanup')
#   qids_array = opts['qids'].map { |q| {'qid' => q}  }
#   should = to_term_filter(qids_array)
#
#   query = build_query(must, should, nil, opts['start_date'], opts['end_date'])
#   response = search query
#   hashie = Hashie::Mash.new JSON.parse response
#   hashie.hits.hits.map { |h| h._source.messageid }.uniq
# end
