class RemoveUserFromProjectsAndAddMemberToProjects < ActiveRecord::Migration[5.0]
    def change
        remove_reference :projects, :user, foreign_key: true
        add_reference :projects, :member, foreign_key: true
    end
end
