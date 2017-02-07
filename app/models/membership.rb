class Membership < ApplicationRecord
    belongs_to :employer, class_name: 'User'
    belongs_to :employee, class_name: 'User'

    validates_uniqueness_of :employer_id, scope: [:employee_id]
end
