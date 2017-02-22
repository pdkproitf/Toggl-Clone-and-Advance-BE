class RenameProjectCategoryUserToProjectCategoryMember < ActiveRecord::Migration[5.0]
    def change
        rename_table :project_category_users, :project_category_members
        remove_reference :project_category_members, :user, foreign_key: true
        add_reference :project_category_members, :member, foreign_key: true
    end
end
