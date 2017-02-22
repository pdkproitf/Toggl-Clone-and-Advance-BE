class ProjectMember < ApplicationRecord
    belongs_to :project
    belongs_to :member

    validates_uniqueness_of :project_id, scope: :member_id
end
