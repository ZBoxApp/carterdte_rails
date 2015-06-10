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
  
  def display_msg_type(message)
    if message.dte
      return "DTE #{message.dte.msg_type.upcase}" unless message.dte.msg_type.nil?
    else
      return "DTE"
    end
  end
  
  def display_log_field(field)
    text = ""
    if field.is_a? Array
      text = field.uniq.join(", ")
    else
      text = field
    end
    text
  end
  
  def pagination_link(page)
    new_params = params.merge(page: page)
    new_params.delete('action')
    new_params.delete('controller')
    send("#{params[:controller]}_path", new_params)
  end

end
