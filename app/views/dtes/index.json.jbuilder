json.array!(@dtes) do |dte|
  json.extract! dte, :id, :folio, :rut_receptor, :rut_emisor, :msg_type, :setdte_id, :dte_type, :fecha_emision, :fecha_recepcion, :account_id, :message_id
  json.url dte_url(dte, format: :json)
end
