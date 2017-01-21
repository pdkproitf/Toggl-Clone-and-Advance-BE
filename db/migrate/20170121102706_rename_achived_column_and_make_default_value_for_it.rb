class RenameAchivedColumnAndMakeDefaultValueForIt < ActiveRecord::Migration[5.0]
  def change
    rename_column :projects, :archived, :is_archived
    change_column_default :projects, :is_archived, false
  end
end
