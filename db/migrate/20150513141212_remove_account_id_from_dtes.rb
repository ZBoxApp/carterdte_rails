class RemoveAccountIdFromDtes < ActiveRecord::Migration
  def change
    remove_column :dtes, :account_id
  end
end
