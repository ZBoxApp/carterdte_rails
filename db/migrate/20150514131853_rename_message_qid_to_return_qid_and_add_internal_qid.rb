class RenameMessageQidToReturnQidAndAddInternalQid < ActiveRecord::Migration
  def change
    rename_column :messages, :qid, :return_qid
    add_column :messages, :qid, :string
  end
end