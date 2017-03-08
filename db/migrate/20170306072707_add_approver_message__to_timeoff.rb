class AddApproverMessageToTimeoff < ActiveRecord::Migration[5.0]
  def change
    add_column :time_offs, :approver_messages, :text
  end
end
