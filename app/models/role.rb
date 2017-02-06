class Role < ApplicationRecord
    validates :name, presence: true, uniqueness: true
    has_many :project_user_roles, dependent: :destroy
    has_many :users, through: :project_user_roles
    has_many :projects, through: :project_user_roles
end