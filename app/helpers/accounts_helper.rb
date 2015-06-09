module AccountsHelper
  
  def customer_of(account)
    return 'IT Linux' if account.itlinux?
    return 'ZBox' if account.zbox_mail?
    return 'Cuenta Admin'
  end
  
  def jail_by(account)
    return 'Servidores' if account.itlinux?
    return 'Dominios' if account.zbox_mail?
    'Sin restricción'
  end
  
  def display_jails(account)
    begin
      # Esto es porque creamos un nuevo host en Account#show
      # para el form de restricciones
      jails = account.jail_elements.all.map { |j| j if j.persisted? }
      # No tiene jail
      return render(partial: "accounts/show/empty_jail") if jails.empty?
      render partial: "accounts/show/jails", locals: {jails: jails}
    rescue Errors::MissingAccountJail => e
      render partial: "accounts/show/empty_jail"
    end
  end
  
  def display_restriction_modal(account)
    return render(:partial => "accounts/show/new_domain") if account.zbox_mail?
    render(:partial => "accounts/show/new_server")
  end
  
end
