class AddDomainAndOvertimeMaxToCompanies < ActiveRecord::Migration[5.0]
  def change
    add_column :companies, :domain, :string
    add_column :companies, :overtime_max, :int
  end
end
