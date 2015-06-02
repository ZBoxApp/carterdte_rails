class SessionsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:new, :create]
  layout "login"

  def new
  end

  def create
    render :text => request.env["omniauth.auth"].extra["displayName"]
  end

  def destroy
  end

  def failure
  end
end
