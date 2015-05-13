class Dte < ActiveRecord::Base
  
  belongs_to :message
  belongs_to :account
  
  def account
    message.account
  end
  
  def account_id
    account.id
  end
  
end
