require 'elasticsearch/model'

# Esta clase es la que busca cosas
class SearchMessage
  include ActiveModel::Model
  include Elasticsearch::Model

  # Configuramos el nombre
  index_name { "logstash-#{build_index_name}" }
  document_type ''

  def self.build_index_name(name = nil)
    return Time.zone.today.to_s.gsub(/-/, '.') unless name
  end
end
