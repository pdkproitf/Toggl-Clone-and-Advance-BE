class TimeOff < ApplicationRecord
    enum status: [:prepare, :pending, :rejected, :approved, :archived]

    belongs_to :sender, class_name: 'Member'
    # belongs_to :approver, class_name: 'Member'
    validates_presence_of   :start_date, :end_date, :is_start_half_day, :is_end_half_day, :description
    validate :time_valid

    private
    def time_valid
        errors.add(:start_date,'Start time have to less than end time') if self.start_date >= self.end_date
    end
end
