class Project < ApplicationRecord
    belongs_to :client
    has_many :project_categories, dependent: :destroy
    has_many :categories, through: :project_categories
    has_many :project_user_roles, dependent: :destroy
    has_many :users, through: :project_user_roles
    has_many :roles, through: :project_user_roles

    validates :name, presence: true, length: { minimum: 6 }
end
