module MessagesHelper

  def delivery_class(message)
    return 'success' if message.delivery_status == 'sent'
    return 'warning' if message.delivery_status == 'partial'
    return 'primary' if message.delivery_status == 'enqueued'
    return 'danger2'
  end

end
