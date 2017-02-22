class RenameProjectCategoryMember < ActiveRecord::Migration[5.0]
    def change
        rename_table :project_category_members, :category_members
        remove_column :category_members, :project_category_id
        add_reference :category_members, :category, foreign_key: true
    end
end
