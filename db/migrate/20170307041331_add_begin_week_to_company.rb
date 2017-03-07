class AddBeginWeekToCompany < ActiveRecord::Migration[5.0]
  def change
    add_column :companies, :begin_week, :Integer, default: 1
  end
end
