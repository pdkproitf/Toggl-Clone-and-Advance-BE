class AddDayOffedToMembers < ActiveRecord::Migration[5.0]
    def change
        rename_column :members, :furlough_total, :total_day_off
        add_column  :members, :day_offed, :Float, default: 0
    end
end
