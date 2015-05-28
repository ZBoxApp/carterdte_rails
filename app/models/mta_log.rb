class MtaLog

  attr_reader :data

  def initialize(raw_source)
    @data = process_responce raw_source
  end

  # Cuando llamen a un metodo
  # lo pasamos al hash
  def method_missing(m, *args, &block)
    @data[m]
  end

  private

  def process_responce(raw)
    raw['timestamp'] = Time.parse raw['@timestamp']
    raw
  end

end
