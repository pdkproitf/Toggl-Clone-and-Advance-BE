class ProjectCategoryUser < ApplicationRecord
  belongs_to :project_category
  belongs_to :user
end
