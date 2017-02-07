class Membership < ApplicationRecord
    belongs_to :employer, class_name: 'User'
    belongs_to :employee, class_name: 'User'
end
