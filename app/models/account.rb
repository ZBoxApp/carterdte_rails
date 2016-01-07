class Account < ActiveRecord::Base

  has_many :users, dependent: :destroy
  has_many :dte_messages, dependent: :destroy
  has_many :dtes, dependent: :destroy
  has_many :servers, dependent: :destroy
  has_many :domains, dependent: :destroy

  validates_presence_of :name
  validates_uniqueness_of :zendesk_id

  def jail
    return false if admin?
    jail_arr = zbox_mail? ? zbox_jail : itlinux_jail
    raise Errors::MissingAccountJail if jail_arr.empty?
    jail_arr
  end
  
  def itlinux?
    !zbox_mail? && !admin?
  end

  def itlinux_jail
    servers.map { |s| { 'host' => s.name } }
  end
  
  def jail_elements
    return [] if admin?
    zbox_mail? ? domains : servers
  end

  def zbox_jail
    from_domain = domains.map { |d| { 'from_domain' => d.name } }
    to_domain = domains.map { |d| { 'to_domain' => d.name } }
    from_domain + to_domain
  end

  def self.get_info_from_zendesk(zendesk_id)
    zacc = zendesk_client.organizations.find(id: zendesk_id)
    { name: zacc.name,
      zbox_mail: zacc['tags'].include?('zbox'),
      zendesk_id: zacc.id.to_i
    }
  end

end
