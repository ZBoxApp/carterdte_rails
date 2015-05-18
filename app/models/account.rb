class Account < ActiveRecord::Base

  has_many :users, dependent: :destroy
  has_many :messages, dependent: :destroy
  has_many :dtes, dependent: :destroy

  validates_presence_of :name
  validates_uniqueness_of :zendesk_id

  def itlinux?
    !zbox_mail?
  end

  def self.get_info_from_zendesk(zendesk_id)
    zacc = zendesk_client.organizations.find(id: zendesk_id)
    { name: zacc.name,
      zbox_mail: zacc['tags'].include?('zbox'),
      zendesk_id: zacc.id.to_i
    }
  end


  def self.zendesk_client
    @zendesk_client ||= ZendeskAPI::Client.new do |config|
      # Mandatory:

      config.url = "#{Figaro.env.zendesk_url}/api/v2"

      # Basic / Token Authentication
      config.username = Figaro.env.zendesk_username

      # Choose one of the following depending on your authentication choice
      config.token = Figaro.env.zendesk_token
    end
  end

end
