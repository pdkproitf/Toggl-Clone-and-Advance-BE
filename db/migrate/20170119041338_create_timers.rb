class CreateTimers < ActiveRecord::Migration[5.0]
  def change
    create_table :timers do |t|
      t.references :task, foreign_key: true
      t.datetime :start_time
      t.datetime :stop_time

      t.timestamps
    end
  end
end
