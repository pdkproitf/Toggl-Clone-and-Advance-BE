class ChangeMemberDayoffColumn < ActiveRecord::Migration[5.0]
    def change
        change_column :members, :total_day_off, :Float, default: 0
        
    end
end
