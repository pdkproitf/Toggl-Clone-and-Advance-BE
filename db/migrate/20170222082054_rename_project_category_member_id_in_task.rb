class RenameProjectCategoryMemberIdInTask < ActiveRecord::Migration[5.0]
    def change
        remove_column :tasks, :project_category_member_id
        add_reference :tasks, :category_member, foreign_key: true
    end
end
