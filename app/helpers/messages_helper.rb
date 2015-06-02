module MessagesHelper

  def delivery_status_text(message)
    return 'Enviado' if message.delivery_status == 'sent'
    return 'Envio parcial' if message.delivery_status == 'partial'
    return 'Procesando...' if message.delivery_status == 'enqueued'
    return 'No fue enviado'
  end
  
  def display_message_to(message)
    truncate(message.to.join(", "), length: 100)
  end

end
