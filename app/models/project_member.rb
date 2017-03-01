class ProjectMember < ApplicationRecord
    belongs_to :project
    belongs_to :member

    validates_uniqueness_of :project_id, scope: :member_id

    def archive
        update_attributes(is_archived: true)
        # Archive all category members
        category_members = project.assigned_members.where(member_id: member_id)
        category_members.each(&:archive)
    end

    def unarchive
        update_attributes(is_archived: false)
        # Unarchive all category members
        category_members = project.assigned_members.where(member_id: member_id)
        category_members.each(&:unarchive)
    end
end
