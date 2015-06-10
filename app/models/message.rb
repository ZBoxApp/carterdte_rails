class Message

  attr_reader :id, :from, :to, :from_domain, :to_domain, :result
  attr_reader :status, :size, :account_id, :timestamp, :logtrace, :account
  attr_accessor :messageid

  def initialize(id: nil, source: nil, account_id: nil)
    @id = id
    @account_id = account_id
    @account = Account.find account_id
    @qids = nil
    get_message_data source
  end

  def delay
    logtrace.first.timestamp - logtrace.last.timestamp
  end

  def delivery_scores
    scores = Hash.new(0)
    delivery_logs.each do |l|
      scores[l.result] += 1
    end
    scores
  end

  def delivery_status
    scores = delivery_scores
    return 'sent' if scores['sent'] == to.size
    return 'partial' if scores['sent'] > 0 && scores['sent'] < to.size
    return 'enqueued' if scores['sent'] == 0 && scores['bounce'] == 0
    'failed'
  end

  def delivery_logs
    deliver_trace = logtrace.select { |l| l.qid == qids.first }
    deliver_trace.select { |l| l.tags.include?('relay') }
  end
  
  
  # Devuelve un arreglo con la traza de logs
  # Ordenado del mas nuevo al mas viejo
  def logtrace
    return @logtrace unless @logtrace.nil?
    s_date = timestamp.to_date.yesterday
    e_date = timestamp.to_date.tomorrow
    trace = []
    qids.each do |qid|
      query = SearchLogQuery.by_qid(qid)
      # Solo usamos Jail si es itlinux.cl, ya que es en base a host
      # no podemos usarla en base a dominios ya que devuelve nada
      jail = account.itlinux? ? account.jail : []
      search_log = SearchLog.new jail: jail, query: query, s_date: s_date, e_date: e_date
      result = search_log.execute
      trace << result.hits.map { |r| MtaLog.new(r._source) }
    end
    trace.each do |l|
      l.sort! {|a,b| b.timestamp <=> a.timestamp }
    end
    @logtrace = trace.flatten
  end

  # Devuelve un arreglo con todos los QIDs del Message
  # Ordenado de mas nuevo a mas viejo
  def qids
    return @qids unless @qids.nil?
    s_date = timestamp.to_date.yesterday
    e_date = timestamp.to_date.tomorrow
    # TODO: Sacar este bug en Julio
    bug_timestamp = Time.parse("2015-05-28 12:55:00 UTC")
    msgid = timestamp < bug_timestamp ? "#{messageid}>" : messageid
    query = SearchLogQuery.by_messageid(msgid)
    search_log = SearchLog.new jail: account.jail, query: query, s_date: s_date, e_date: e_date
    result = search_log.execute
    @qids = result.hits.map { |r| r._source.qid }
  end

  def self.find(account, id)
    search = SearchLog.find(account.jail, id)
    msg = search.hits.first
    Message.new(id: msg._id, source: msg._source, account_id: account.id)
  end
  
  def self.from_by_page(pnumber = nil)
    return 0 if pnumber.nil?
    return 0 if pnumber <= 1
    from = ((pnumber.to_i - 1) * SearchLog::SEARCH_SIZE) + 1
    from
  end

  def self.search(account: nil, from: nil, to: nil, s_date: nil, e_date: nil, page: 1)
    fail '<Message#search> Account nil' unless account.is_a? Account
    query = SearchLogQuery.amavisd_by_emails(from: from, to: to)
    search_log = SearchLog.new jail: account.jail, query: query, s_date: s_date, e_date: e_date
    result = search_log.execute(from_by_page(page))
    result.results = result.hits.map { |r| Message.new(id: r._id, source: r._source, account_id: account.id) }
    result
  end

  private
  def get_message_data(source)
    @messageid = source.messageid
    @from = source.from
    @to = source.to.is_a?(Array) ? source.to.uniq : [source.to]
    @from_domain = source.from_domain
    @to_domain = source.to_domain.is_a?(Array) ? source.to_domain.uniq : [source.to_domain]
    @result = source.result
    @status = source.status
    @size = source['size'].to_i unless source['size'].nil?
    @timestamp = Time.parse source['@timestamp'] unless source['@timestamp'].nil?
  end

end
