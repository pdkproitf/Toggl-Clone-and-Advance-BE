class AddIncreDayoffToCompany < ActiveRecord::Migration[5.0]
    def change
        add_column :companies, :incre_dayoff, :boolean, default: :false
    end
end
