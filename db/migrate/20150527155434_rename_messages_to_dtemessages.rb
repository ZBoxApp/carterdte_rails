class RenameMessagesToDtemessages < ActiveRecord::Migration
  def change
    rename_table :messages, :dte_messages
    rename_column :dtes, :message_id, :dte_message_id
  end
end
