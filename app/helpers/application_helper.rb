module ApplicationHelper
  
  def active_menu?(controller)
    "active" if params[:controller] == controller
  end
  
  def dte_page_link(page)
    new_params = params.merge(page: page)
    new_params.delete('action')
    new_params.delete('controller')
    dte_messages_path(new_params)
  end
  
end
