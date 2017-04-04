class ChangeJobMemberColumn < ActiveRecord::Migration[5.0]
    def change
        remove_reference :jobs_members, :company, foreign_key: true
        remove_reference :jobs_members, :job, foreign_key: true
        add_reference :jobs_members, :company_job, foreign_key: true
    end
end
