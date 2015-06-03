class DteMessage < ActiveRecord::Base

  attr_reader :mta_message

  belongs_to :account
  has_one :dte, dependent: :destroy
  delegate :rut_receptor, to: :dte

  accepts_nested_attributes_for :dte, :allow_destroy => true

  validates_uniqueness_of :message_id, :on => :create, :message => "must be unique"
  before_save :format_fields
  
  scope :by_account, ->(account) { where(account_id: account.id)}
  
  def mta_message
    source = OpenStruct.new
    source.messageid = message_id
    source.from = from
    source.to = to
    source['@timestamp'] = sent_date.to_s(:db)
    @mta_message ||= Message.new(account_id: account.id, source: source)
    @mta_message
  end
  
  def logtrace
    @mta_message.logtrace
  end
  
  private
  def format_fields
    downcase_email
  end
  
  def downcase_email
    self.to = to.downcase unless to.nil?
    self.from = from.downcase unless from.nil?
  end

end
