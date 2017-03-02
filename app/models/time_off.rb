class TimeOff < ApplicationRecord
    enum status: [:pending, :approved, :rejected, :archived]

    belongs_to :sender, class_name: 'Member'
    belongs_to :approver, class_name: 'Member'

    validates_presence_of   :start_date, :end_date, :description
    validate :time_valid

    private
    def time_valid
        errors.add(:start_date,'have to less than end date') if self.start_date > self.end_date
    end
end
