class AddArchivedToMembers < ActiveRecord::Migration[5.0]
    def change
        add_column :members, :is_archived, :boolean, default: false
    end
end
