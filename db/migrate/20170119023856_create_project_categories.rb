class CreateProjectCategories < ActiveRecord::Migration[5.0]
  def change
    create_table :project_categories do |t|
      t.references :project, foreign_key: true
      t.references :category, foreign_key: true
      t.boolean :billable

      t.timestamps
    end
  end
end
