class RenameReferenceColumnInTask < ActiveRecord::Migration[5.0]
  def change
    rename_column :tasks, :project_category_users_id, :project_category_user_id
  end
end
