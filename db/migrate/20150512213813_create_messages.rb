class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.string :to
      t.string :from
      t.text :message_id
      t.string :cc
      t.date :sent_date
      t.string :qid
      t.integer :account_id

      t.timestamps null: false
    end
    add_index :messages, :to
    add_index :messages, :from
    add_index :messages, :account_id
  end
end