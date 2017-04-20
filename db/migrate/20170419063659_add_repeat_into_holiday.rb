class AddRepeatIntoHoliday < ActiveRecord::Migration[5.0]
    def change
        add_column :holidays, :is_repeat, :boolean, default: false
    end
end
