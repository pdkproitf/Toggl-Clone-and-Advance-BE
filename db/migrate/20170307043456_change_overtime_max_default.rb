class ChangeOvertimeMaxDefault < ActiveRecord::Migration[5.0]
  def change
    change_column_default :companies, :overtime_max, 40
  end
end
