class CreateHolidays < ActiveRecord::Migration[5.0]
  def change
    create_table :holidays do |t|
      t.string :name, null: false
      t.datetime :begin_day, null: false
      t.datetime :end_day, null: false

      t.timestamps
    end
  end
end
