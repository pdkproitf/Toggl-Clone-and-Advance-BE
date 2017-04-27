class AddIsApprovedToTimer < ActiveRecord::Migration[5.0]
  def change
    add_column :timers, :is_approved, :boolean, default: :false
  end
end
