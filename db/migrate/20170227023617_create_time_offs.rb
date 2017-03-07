class CreateTimeOffs < ActiveRecord::Migration[5.0]
  def change
    create_table :time_offs do |t|
      t.datetime :start_date
      t.datetime :end_date
      t.boolean :is_start_half_day
      t.boolean :is_end_half_day
      t.text :description
      t.boolean :approver_id
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
