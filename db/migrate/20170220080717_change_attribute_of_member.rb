class ChangeAttributeOfMember < ActiveRecord::Migration[5.0]
    def change
        remove_column :members, :employer_id
        remove_column :members, :employee_id
        add_reference :members, :company, foreign_key: true
        add_reference :members, :user, foreign_key: true
        add_column :members, :role, :integer
        add_column :members, :furlough_total, :integer
    end
end
