class UpdateFkTask < ActiveRecord::Migration[5.0]
    def change
        remove_column :tasks, :project_category_user_id
        add_reference :tasks, :project_category_member, foreign_key: true
    end
end
