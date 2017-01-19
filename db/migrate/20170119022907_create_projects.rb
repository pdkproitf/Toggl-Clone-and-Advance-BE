class CreateProjects < ActiveRecord::Migration[5.0]
    def change
        create_table :projects do |t|
            t.string :name
            t.references :client, foreign_key: true
            t.string :background
            t.integer :report_permission
            t.boolean :archived

            t.timestamps
        end
    end
end
