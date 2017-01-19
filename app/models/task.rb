class Task < ApplicationRecord
    belongs_to :project_category_users
    has_many :timers
end
