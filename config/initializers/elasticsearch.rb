Elasticsearch::Model.client = Elasticsearch::Client.new(
  log: true,
  host: ENV['elasticsearch_host']
)
