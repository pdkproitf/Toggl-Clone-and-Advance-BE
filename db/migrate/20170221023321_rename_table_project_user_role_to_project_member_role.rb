class RenameTableProjectUserRoleToProjectMemberRole < ActiveRecord::Migration[5.0]
    def change
        rename_table :project_user_roles, :project_member_roles
        remove_reference :project_member_roles, :role, foreign_key: true
        add_column :project_member_roles, :is_pm, :boolean, default: false
        remove_reference :project_member_roles, :user, foreign_key: true
        add_reference :project_member_roles, :member, foreign_key: true
    end
end
