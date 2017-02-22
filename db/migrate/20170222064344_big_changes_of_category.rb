class BigChangesOfCategory < ActiveRecord::Migration[5.0]
    def change
        remove_reference :project_categories, :category, foreign_key: true
        drop_table :categories
        rename_table :project_categories, :categories
        add_column :categories, :name, :string
    end
end
