class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :verify_authenticity_token, only: :zimbraadmin

  def zimbraadmin
      # You need to implement the method below in your model (e.g. app/models/user.rb)
      @user = User.from_omniauth(request.env["omniauth.auth"])

      if @user.persisted?
        sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
        set_flash_message(:notice, :success, :kind => "ZBox") if is_navigational_format?
      else
        session["devise.zimbraadmin_data"] = request.env["omniauth.auth"].select { |k, v| k == "email" }
        redirect_to new_user_registration_url
      end
    end
end
