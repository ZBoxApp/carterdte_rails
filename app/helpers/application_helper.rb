module ApplicationHelper
  
  def active_menu?(controller)
    "active" if params[:controller] == controller
  end
  
end
