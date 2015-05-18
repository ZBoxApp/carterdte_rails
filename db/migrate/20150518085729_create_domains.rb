class CreateDomains < ActiveRecord::Migration
  def change
    create_table :domains do |t|
      t.string :name
      t.integer :account_id

      t.timestamps null: false
    end
    add_index :domains, :account_id
  end
end
