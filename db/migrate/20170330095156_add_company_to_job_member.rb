class AddCompanyToJobMember < ActiveRecord::Migration[5.0]
  def change
      add_reference :jobs_members, :company, foreign_key: true
  end
end
