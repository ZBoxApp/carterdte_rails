class Dte < ActiveRecord::Base

  belongs_to :dte_message
  belongs_to :account

  def account
    dte_message.account
  end

  def account_id
    account.id
  end

end
