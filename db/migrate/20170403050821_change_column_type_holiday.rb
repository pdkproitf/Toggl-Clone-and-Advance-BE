class ChangeColumnTypeHoliday < ActiveRecord::Migration[5.0]
  def change
     change_column :holidays, :begin_date, :datetime
     change_column :holidays, :end_date, :datetime
  end
end
