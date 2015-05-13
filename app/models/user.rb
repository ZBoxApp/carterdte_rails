class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :omniauthable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauth_providers => [:zendesk]
         
  belongs_to :account

  def system?
    role == "system"
  end
  
  def user?
    !system?
  end
         
  def self.from_omniauth(auth)
   where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
     Rails.logger.debug auth.inspect
     user.uid = auth.uid
     user.email = auth.info.email
     user.password = Devise.friendly_token[0,20]
     user.name = auth.info.name   # assuming the user model has a name
     user.image = auth.info.image # assuming the user model has an image
     user.role = auth.info.role.nil? ? nil : auth.info.role.split(/\"/).second
     user.description = auth.info.description
     Rails.logger.debug user.valid?
     Rails.logger.debug user.errors.messages
   end
  end
  
  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.zendesk_data"] && session["devise.zendesk_data"]["extra"]["raw_info"]
        user.email = data["email"] if user.email.blank?
        end
      end 
    end
    
end
