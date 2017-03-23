class UpdateArchiveCategoryMember < ActiveRecord::Migration[5.0]
  def change
    rename_column :category_members, :is_archived_by_category, :is_archived
    remove_column :category_members, :is_archived_by_project_member
  end
end
