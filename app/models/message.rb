class Message

  attr_reader :id, :messageid, :from, :to, :from_domain, :to_domain, :result
  attr_reader :status, :size, :account_id, :timestamp

  def initialize(id: nil, source: nil, account_id: nil)
    @id = id
    @account_id = account_id
    get_message_data source
  end

  def account
    Account.find account_id
  end

  def qids
    s_date = timestamp.to_date.yesterday
    e_date = timestamp.to_date.tomorrow
    # TODO: Sacar este bug en Julio
    bug_timestamp = Time.parse("2015-05-28 12:55:00 UTC")
    msgid = timestamp < bug_timestamp ? "#{messageid}>" : messageid
    query = SearchLogQuery.by_messageid(msgid)
    search_log = SearchLog.new jail: account.jail, query: query, s_date: s_date, e_date: e_date
    result = search_log.execute
    result.hits.map { |r| r._source.qid }
  end

  def self.find(account, id)
    search = SearchLog.find(account.jail, id)
    msg = search.hits.first
    Message.new(id: msg._id, source: msg._source, account_id: account.id)
  end

  def self.search(account: nil, from: nil, to: nil, s_date: nil, e_date: nil)
    fail '<Message#search> Account nil' unless account.is_a? Account
    query = SearchLogQuery.amavisd_by_emails(from: from, to: to)
    search_log = SearchLog.new jail: account.jail, query: query, s_date: s_date, e_date: e_date
    result = search_log.execute
    result.results = result.hits.map { |r| Message.new(id: r._id, source: r._source, account_id: account.id) }
    result
  end

  private
  def get_message_data(source)
    @messageid = source.messageid
    @from = source.from
    @to = source.to.is_a?(Array) ? source.to : [source.to]
    @from_domain = source.from_domain
    @to_domain = source.to_domain.is_a?(Array) ? source.to_domain : [source.to_domain]
    @result = source.result
    @status = source.status
    @size = source['size'].to_i
    @timestamp = Time.parse source['@timestamp']
  end

end
