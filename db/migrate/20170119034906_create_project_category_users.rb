class CreateProjectCategoryUsers < ActiveRecord::Migration[5.0]
    def change
        create_table :project_category_users do |t|
            t.references :project_category, foreign_key: true, index: true
            t.references :user, foreign_key: true, index: true

            t.timestamps
        end
    end
end
