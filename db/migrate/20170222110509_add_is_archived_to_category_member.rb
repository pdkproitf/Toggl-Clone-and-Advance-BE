class AddIsArchivedToCategoryMember < ActiveRecord::Migration[5.0]
    def change
        add_column :category_members, :is_archived, :boolean, default: false
    end
end
