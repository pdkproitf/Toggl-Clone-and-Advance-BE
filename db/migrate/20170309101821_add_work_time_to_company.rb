class AddWorkTimeToCompany < ActiveRecord::Migration[5.0]
  def change
    rename_column :companies, :overtime_max, :working_time_per_day
    change_column_default :companies, :working_time_per_day, 8
    add_column :companies, :working_time_per_week, :Integer, default: 40
  end
end
