class AddZboxAndDteFieldsToAccount < ActiveRecord::Migration
  def change
    add_column :accounts, :zbox_mail, :boolean, default: false
    add_column :accounts, :dte_default, :boolean, default: false
  end
end
