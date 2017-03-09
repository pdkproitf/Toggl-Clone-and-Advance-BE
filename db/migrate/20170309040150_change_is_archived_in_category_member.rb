class ChangeIsArchivedInCategoryMember < ActiveRecord::Migration[5.0]
  def change
    rename_column :category_members, :is_archived, :is_archived_by_category
    add_column :category_members, :is_archived_by_project_member,
               :boolean, default: false
  end
end
