class TimeOff < ApplicationRecord
    enum status: [:prepare, :pending, :rejected, :approved]

    belongs_to :sender, class_name: 'Member'
    belongs_to :approver, class_name: 'Member'
end
