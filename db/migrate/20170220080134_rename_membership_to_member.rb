class RenameMembershipToMember < ActiveRecord::Migration[5.0]
    def change
        rename_table :memberships, :members
    end
end
