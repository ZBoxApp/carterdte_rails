class AddRutsToDteMessages < ActiveRecord::Migration
  def change
    add_column :dte_messages, :rut_emisor, :string
    add_column :dte_messages, :rut_receptor, :string
    
    add_index :dte_messages, :rut_receptor
    add_index :dte_messages, :rut_emisor
  end
end