class Account < ActiveRecord::Base
  
  has_many :users, dependent: :destroy
  has_many :messages, dependent: :destroy
  has_many :dtes, dependent: :destroy
  
end
