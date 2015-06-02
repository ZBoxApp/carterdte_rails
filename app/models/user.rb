class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :omniauthable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauth_providers => [:zendesk]

  belongs_to :account

  after_create :set_account_id

  def admin?
    role == "admin"
  end

  def domains_name
    account.domains.map(&:name)
  end

  def itlinux?
    !zbox_mail?
  end

  def zbox_mail?
    account.zbox_mail?
  end

  def servers_name
    account.servers.map(&:name)
  end

  def system?
    role == "system"
  end

  def user?
    !system?
  end

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.uid = auth.uid
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.name = auth.info.name   # assuming the user model has a name
      user.image = auth.info.image # assuming the user model has an image
      # El role puede ser admin o end-user
      user.role = auth.info.role.nil? ? nil : auth.info.role.name
      user.description = auth.info.description
      user.zendesk_account_id = auth.extra.raw_info.organization_id.to_i
    end
  end

  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session['devise.zendesk_data'] && session['devise.zendesk_data']['extra']['raw_info']
        user.email = data['email'] if user.email.blank?
      end
    end
  end

  private

  def set_account_id
    account = find_account(zendesk_account_id)
    self.account_id = account.id
    save
  end

  def find_account(zendesk_account_id)
    Account.where(zendesk_id: zendesk_account_id).first_or_create do |account|
      zendesk_info = Account.get_info_from_zendesk(zendesk_account_id)
      account.name = zendesk_info[:name]
      account.zbox_mail = zendesk_info[:zbox_mail]
      account.zendesk_id = zendesk_info[:zendesk_id]
    end
  end

end
