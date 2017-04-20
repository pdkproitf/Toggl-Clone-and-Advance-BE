class AddTypeToHoliday < ActiveRecord::Migration[5.0]
    def change
        add_column :holidays, :kind, :Integer, default: 0
    end
end
