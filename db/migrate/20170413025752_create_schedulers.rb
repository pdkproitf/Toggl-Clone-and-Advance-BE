class CreateSchedulers < ActiveRecord::Migration[5.0]
  def change
    create_table :schedulers do |t|
      t.string :name
      t.integer :frequency
      t.string :at
      t.references :clock_job, foreign_key: true, index: true
      t.jsonb :clock_job_arguments

      t.timestamps
    end
  end
end
