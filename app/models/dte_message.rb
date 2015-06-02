class DteMessage < ActiveRecord::Base

  belongs_to :account
  has_one :dte, dependent: :destroy

  accepts_nested_attributes_for :dte, :allow_destroy => true

  validates_uniqueness_of :message_id, :on => :create, :message => "must be unique"
  before_save :format_fields


  private
  def format_fields
    downcase_email
  end
  
  def downcase_email
    self.to = to.downcase unless to.nil?
    self.from = from.downcase unless from.nil?
  end

end
