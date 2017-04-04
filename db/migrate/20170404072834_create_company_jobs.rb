class CreateCompanyJobs < ActiveRecord::Migration[5.0]
  def change
    create_table :company_jobs do |t|
      t.references :company, foreign_key: true
      t.references :job, foreign_key: true

      t.timestamps
    end
  end
end
