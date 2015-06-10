class Message

  attr_reader :id, :from, :to, :from_domain, :to_domain, :result
  attr_reader :status, :size, :account_id, :timestamp, :logtrace, :account
  attr_accessor :messageid

  def initialize(id: nil, source: nil, account_id: nil)
    @id = id
    @account_id = account_id
    @account = Account.find account_id
    @qids = nil
    @qids_trace = {}
    get_message_data source
  end
  
  # Devuelve un arreglo con los logs que
  # corresponden a las entregas fallidas basado en
  # el tag relay y result = bounced
  def bounce_trace
    result = relay_trace.select { |l| ( l.tags.include?('relay') && l.result.include?('bounced')) }
    result.nil? ? [] : result
  end
  
  # Devuelve un arreglo con los logs que
  # corresponden a las entregas en cola basado en
  # el tag relay y result = deferred
  def deferred_trace
    result = relay_trace.select { |l| ( l.tags.include?('relay') && l.result.include?('deferred')) }
    result.nil? ? [] : result
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
    return 'enqueued' unless processed?
    return 'sent' if sent_trace.size > 0 && bounce_trace.size == 0
    return 'partial' if (bounce_trace.size > 0 && sent_trace.size > 0)
    return 'failed' if (bounce_trace.size > 0 && sent_trace.size == 0)
    #fail Errors::UnknownDeliveryStatus
    'noidea'
  end

  def delivery_logs
    deliver_trace = logtrace.select { |l| l.qid == qids.first }
    deliver_trace.select { |l| l.tags.include?('relay') }
  end
  
  
  # Devuelve un arreglo con la traza de logs
  # Ordenado del mas nuevo al mas viejo
  def logtrace
    return @logtrace unless @logtrace.nil?
    trace = qids_trace.values
    trace.each do |l|
      l.sort! {|a,b| b.timestamp <=> a.timestamp }
    end
    @logtrace = trace.flatten
  end
  
  # Devuelve verdadero si hay un qmgr con estado removed
  def processed?
    qmgrs = relay_trace.select {|l| ( l.component == 'qmgr' && l.queuestatus == 'removed') }
    qmgrs.any?
  end
  
  # Permite saber cual es el elemento del hash qids_trace
  # que contiene los logs de entrega
  def relay_qid
    qids_trace.keys.first
  end
  
  # Devuelve un arreglo con los logs que
  # corresponden a la entrega del mensaje
  def relay_trace
    qids_trace[relay_qid]
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
    # Solo usamos Jail si es itlinux.cl, ya que es en base a host
    # no podemos usarla en base a dominios ya que devuelve nada
    jail = account.itlinux? ? account.jail : []
    search_log = SearchLog.new jail: jail, query: query, s_date: s_date, e_date: e_date
    result = search_log.execute
    result.hits.sort! {|a,b| Time.parse(b._source["@timestamp"]) <=> Time.parse(a._source["@timestamp"]) }
    @qids = result.hits.map { |r| r._source.qid }
  end
  
  def qids_trace
    return @qids_trace unless @qids_trace.empty?
    s_date = timestamp.to_date.yesterday
    e_date = timestamp.to_date.tomorrow
    qids.each do |qid|
      query = SearchLogQuery.by_qid(qid)
      # Solo usamos Jail si es itlinux.cl, ya que es en base a host
      # no podemos usarla en base a dominios ya que devuelve nada
      jail = account.itlinux? ? account.jail : []
      search_log = SearchLog.new jail: jail, query: query, s_date: s_date, e_date: e_date
      result = search_log.execute
      @qids_trace[qid] = result.hits.map { |r| MtaLog.new(r._source) }
    end
    @qids_trace
  end
  
  # Devuelve un arreglo con los logs que
  # corresponden a las entregas exitosas basado en
  # el tag relay y result = sent
  # usamos include porque puede ser un arreglo
  def sent_trace
    result = relay_trace.select {|l| ( l.tags.include?('relay') && l.result.include?('sent') ) }
    result.nil? ? [] : result
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
