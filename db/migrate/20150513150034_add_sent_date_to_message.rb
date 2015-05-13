class AddSentDateToMessage < ActiveRecord::Migration
    change_column :messages, :sent_date, :time
end