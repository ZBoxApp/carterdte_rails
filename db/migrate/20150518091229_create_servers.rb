class CreateServers < ActiveRecord::Migration
  def change
    create_table :servers do |t|
      t.string :name
      t.integer :account_id

      t.timestamps null: false
    end
    add_index :servers, :account_id
  end
end
