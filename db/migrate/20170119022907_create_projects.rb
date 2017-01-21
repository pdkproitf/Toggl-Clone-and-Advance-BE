class CreateProjects < ActiveRecord::Migration[5.0]
    def change
        create_table :projects do |t|
            t.string :name
            t.references :client, foreign_key: true, index: true
            t.string :background
            t.integer :report_permission
            t.boolean :is_archived, :default => false

            t.timestamps
        end
    end
end
