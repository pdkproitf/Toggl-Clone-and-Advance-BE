class Holiday < ApplicationRecord
    enum kind: [:individual, :traditional, :international]

    belongs_to :company

    validates :name, length: { minimum: 2 }
    validates_presence_of :begin_date, :end_date, :company_id
    validate :valid_start_end_days

    private
    include DaysValidates

    # begin_date_cannot_be_greater_than_end_date
    def valid_start_end_days
        days_valid?(begin_date, 'begin_date', end_date)
    end
end
