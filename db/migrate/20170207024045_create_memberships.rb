class CreateMemberships < ActiveRecord::Migration[5.0]
  def change
    create_table :memberships do |t|
      t.integer :employer_id
      t.integer :employee_id

      t.timestamps
    end
  end
end
