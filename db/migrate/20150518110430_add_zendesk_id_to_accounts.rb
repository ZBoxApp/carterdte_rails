class AddZendeskIdToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :zendesk_id, :integer
    add_index :accounts, :zendesk_id
  end
end
