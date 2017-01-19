class ProjectCategory < ApplicationRecord
    belongs_to :project
    belongs_to :category
    has_many :project_category_user
    has_many :users, through: :project_category_users
end
