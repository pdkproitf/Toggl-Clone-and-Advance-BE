class RenameProjectMemberToProjectMember < ActiveRecord::Migration[5.0]
    def change
        rename_table :project_member_roles, :project_members
    end
end
