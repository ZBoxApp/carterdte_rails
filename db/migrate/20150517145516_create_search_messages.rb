class CreateSearchMessages < ActiveRecord::Migration
  def change
    create_table :search_messages do |t|

      t.timestamps null: false
    end
  end
end
