class CreateDtes < ActiveRecord::Migration
  def change
    create_table :dtes do |t|
      t.integer :folio
      t.string :rut_receptor
      t.string :rut_emisor
      t.string :msg_type
      t.string :setdte_id
      t.integer :dte_type
      t.date :fecha_emision
      t.date :fecha_recepcion
      t.integer :account_id
      t.integer :message_id

      t.timestamps null: false
    end
    add_index :dtes, :rut_emisor
    add_index :dtes, :rut_receptor
    add_index :dtes, :dte_type
    add_index :dtes, :account_id
  end
end