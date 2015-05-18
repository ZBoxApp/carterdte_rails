class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :verify_authenticity_token, only: :zendesk

  def zendesk
      # You need to implement the method below in your model (e.g. app/models/user.rb)
      Rails.logger.debug("----- AQUI #{request.env['omniauth.auth'].extra.raw_info.organization_id}")
      @user = User.from_omniauth(request.env["omniauth.auth"])

      if @user.persisted?
        sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
        set_flash_message(:notice, :success, :kind => "Zendesk") if is_navigational_format?
      else
        session["devise.zendesk_data"] = request.env["omniauth.auth"]
        redirect_to new_user_registration_url
      end
    end
end
