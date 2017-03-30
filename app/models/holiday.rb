class Holiday < ApplicationRecord
    belongs_to :company

    validates :name, length: { minimum: 2 }
    validates_presence_of :begin_date, :end_date, :company_id
    validate :valid_start_end_days
    validate :conflict_holiday, on: :create
    validate :conflict_holiday_update, on: :update

    private
    include DaysValidates

    # begin_date_cannot_be_greater_than_end_date
    def valid_start_end_days
        days_valid?(begin_date, end_date, 'begin_date')
    end

    def conflict_holiday
        conflict_date?(Holiday.where(company_id: company_id), 'begin_date', begin_date, end_date)
    end

    def conflict_holiday_update
        conflict_date?(Holiday.where(company_id: company_id), 'begin_date', begin_date, end_date, id)
    end
end
