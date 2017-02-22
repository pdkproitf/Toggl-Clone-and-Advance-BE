class AddCompanyToClients < ActiveRecord::Migration[5.0]
  def change
    add_reference :clients, :company, foreign_key: true
  end
end
