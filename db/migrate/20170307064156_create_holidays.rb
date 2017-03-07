class CreateHolidays < ActiveRecord::Migration[5.0]
  def change
    create_table :holidays do |t|
      t.string :name, null: false
      t.date :begin_date, null: false
      t.date :end_date, null: false
      t.references :company, foreign_key: true, index: true

      t.timestamps
    end
  end
end
