class Member < ApplicationRecord
    belongs_to :company
    belongs_to :user
    # validates_uniqueness_of :employer_id, scope: [:employee_id]
end
