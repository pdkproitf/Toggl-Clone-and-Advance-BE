class Task < ApplicationRecord
    belongs_to :project_category_users, optional: true
    has_many :timers, dependent: :destroy
end
