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
  
  def bounce?
    return true if (tags.include?('relay') && result.include?('bounced'))
    return true if component == 'bounce'
    false
  end

  private

  def process_responce(raw)
    raw['timestamp'] = Time.parse raw['@timestamp']
    raw['clean_message'] = parse_message raw['message']
    raw
  end

  def parse_message(message)
    ary = message.split(/ /)
    ary.shift
    ary.shift
    ary.join(" ")
  end

end
