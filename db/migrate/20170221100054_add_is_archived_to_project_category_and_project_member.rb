class AddIsArchivedToProjectCategoryAndProjectMember < ActiveRecord::Migration[5.0]
    def change
        add_column :project_categories, :is_archived, :boolean, default: false
        add_column :project_members, :is_archived, :boolean, default: false
    end
end
