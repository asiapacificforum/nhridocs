class ChangeReminderDateToDatetime < ActiveRecord::Migration[5.0]
  def change
    remove_column :reminders, :start_date, :datetime
    add_column :reminders, :start_date, :datetime
  end
end
