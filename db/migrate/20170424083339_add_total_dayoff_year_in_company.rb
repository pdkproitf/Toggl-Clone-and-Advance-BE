class AddTotalDayoffYearInCompany < ActiveRecord::Migration[5.0]
    def change
        add_column :companies, :year_dayoffs, :Integer, default: 12
    end
end
