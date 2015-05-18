class AddZendeskAccountIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :zendesk_account_id, :integer
  end
end
