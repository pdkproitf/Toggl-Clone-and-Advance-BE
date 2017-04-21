class CreateClockJobs < ActiveRecord::Migration[5.0]
  def change
    create_table :clock_jobs do |t|
      t.string :name

      t.timestamps
    end
  end
end
