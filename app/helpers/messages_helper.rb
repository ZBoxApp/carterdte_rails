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
  
  def pages_link_array(current, total)
    delta = total - current
    return (current..current + 5).to_a if delta > 5
    return (current..total - 1).to_a  if delta <= 5
  end
  
  def show_upper_elipsis?(current, total)
    delta = total - pages_link_array(current, total).last
    return true if delta > 1
    false
  end
  
  def show_down_elipsis?(current)
    return true if current > 2
    false
  end

end
