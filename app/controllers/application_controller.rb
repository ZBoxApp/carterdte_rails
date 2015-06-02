class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :authenticate_user!
  layout :set_layout

  def current_account
    @current_account ||= current_user.account
    @current_account
  end
  
  def set_layout
    return "login" unless current_user
  end

  # Because we are no usign Devise :database_authenticatable
  # https://github.com/plataformatec/devise/wiki/OmniAuth:-Overview
  # def new_session_path(scope)
  #   new_session_path
  # end

  helper_method :current_account

end
