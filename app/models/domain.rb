class Domain < ActiveRecord::Base

  belongs_to :account
  validates_presence_of :account_id, :name
end
