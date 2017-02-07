class ProjectCategoryUser < ApplicationRecord
    belongs_to :project_category, optional: true
    belongs_to :user
    has_many :tasks, dependent: :destroy
end
