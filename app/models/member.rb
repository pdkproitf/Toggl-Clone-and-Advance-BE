class Member < ApplicationRecord
    belongs_to :company
    belongs_to :user
    has_many :projects # Create new
    has_many :joined_projects, through: :project_member_roles, source: :projects
    has_many :project_member_roles, dependent: :destroy

    validates_uniqueness_of :comany_id, scope: [:user_id]
end
