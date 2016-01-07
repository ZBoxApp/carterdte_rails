class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :omniauthable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauth_providers => [:zimbraadmin]

  belongs_to :account

  after_create :set_account_id

  def admin?
    role == "admin"
  end

  def domains_name
    account.domains.map(&:name)
  end
  
  def email_domain_name
    email.split(/@/).second
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
      user.email = auth.uid
      user.password = Devise.friendly_token[0, 20]
      user.name = auth.extra.displayName   # assuming the user model has a name
      user.image = nil # assuming the user model has an image
      # El role puede ser admin o end-user
      user.role = auth.extra.zimbraIsAdminAccount ? 'admin' : 'end-user'
    end
  end

  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session['devise.zimbra_data'] && session['devise.zimbra_data']['extra']['raw_info']
        user.email = data['email'] if user.email.blank?
      end
    end
  end

  private

  def set_account_id
    account = find_account(email_domain_name)
    self.account_id = account.id
    save
  end

  def find_account(domain_name)
    return Account.find_by(admin: true) if admin?
    domain = Domain.find_by(name: domain_name)
    domain.account
  end

end
