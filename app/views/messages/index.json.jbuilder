json.array!(@messages) do |message|
  json.extract! message, :id, :to, :from, :message_id, :cc, :sent_date, :qid, :dte_id, :account_id
  json.url message_url(message, format: :json)
end
