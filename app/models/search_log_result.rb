class SearchLogResult

  attr_reader :current_page, :pages, :total_hits, :raw_hits, :hits, :search_size
  attr_accessor :results, :search

  def initialize(response, from, size, search)
    hashify(response)
    fail '<SearchLog::Error> Error en Search' if @raw_hits.nil?
    fail Errors::NoElasticSearchResults if @raw_hits.total == 0
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
    return self if pnumber == current_page
    return self unless pnumber.is_a? Fixnum
    return self if pnumber <= 1
    from = ((pnumber - 1) * search_size) + 1
    @search.execute(from, search_size)
  end

  def next_page
    return false if current_page == pages
    current_page + 1
  end

  def previous_page
    return false if current_page == 1
    current_page - 1
  end
  
  def total_pages
    pages
  end
  
  def prev_page
    previous_page
  end

end
