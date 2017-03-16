class CreateJobsMembers < ActiveRecord::Migration[5.0]
  def change
    create_table :jobs_members do |t|
      t.references :member, foreign_key: true
      t.references :job, foreign_key: true

      t.timestamps
    end
  end
end
