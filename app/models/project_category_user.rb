class ProjectCategoryUser < ApplicationRecord
    belongs_to :project_category
    belongs_to :user
    has_many :tasks
end
