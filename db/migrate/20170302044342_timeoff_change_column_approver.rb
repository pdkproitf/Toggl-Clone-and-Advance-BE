class TimeoffChangeColumnApprover < ActiveRecord::Migration[5.0]
  def change
      remove_column :time_offs, :approver_id
  end
end
