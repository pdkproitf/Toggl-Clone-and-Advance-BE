class AddUserRefToProjects < ActiveRecord::Migration[5.0]
    def change
        add_reference :projects, :user, after: :name, foreign_key: true, index: true
    end
end
