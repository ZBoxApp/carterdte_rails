class SearchLogResult

  attr_reader :current_page, :pages, :total_hits, :raw_hits, :hits, :search_size
  attr_accessor :results

  def initialize(response, from, size, search)
    hashify(response)
    fail '<SearchLog::Error> Error en Search' if @raw_hits.nil?
    fail ActiveRecord::RecordNotFound if @raw_hits.total == 0
    @hits = @raw_hits.hits
    @total_hits = @raw_hits.total
    @search_size = size
    @pages = (total_hits.to_f / search_size).ceil
    @current_page = from == 0 ? 1 : (from.to_f / search_size).ceil
    @search = search
  end

  def hashify(response)
    hashie = Hashie::Mash.new JSON.parse response
    @raw_hits = hashie.hits
  end

  def page(pnumber = 1)
    return @search.execute(@query) unless pnumber.is_a? Fixnum
    return @search.execute(@query) if pnumber <= 1
    from = ((pnumber - 1) * search_size) + 1
    @search.execute(from, search_size)
  end

end
