class RenameDefaultToProjectRefInProjects < ActiveRecord::Migration[5.0]
    def change
        remove_column :categories, :default
        add_reference :categories, :project, foreign_key: true
    end
end
