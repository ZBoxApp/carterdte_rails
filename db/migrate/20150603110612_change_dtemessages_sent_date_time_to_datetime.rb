class ChangeDtemessagesSentDateTimeToDatetime < ActiveRecord::Migration
  def change
    change_column :dte_messages, :sent_date, :datetime
  end
end