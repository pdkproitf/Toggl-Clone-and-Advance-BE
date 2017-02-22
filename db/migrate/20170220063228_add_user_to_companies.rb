class AddUserToCompanies < ActiveRecord::Migration[5.0]
  def change
    add_reference :companies, :user, foreign_key: true
  end
end
