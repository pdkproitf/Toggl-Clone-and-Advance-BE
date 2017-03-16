class AddAssMemberJob < ActiveRecord::Migration[5.0]
    def change
        create_table :jobs_members, id: false do |t|
            t.belongs_to :member, index: true
            t.belongs_to :job, index: true
        end
    end
end
