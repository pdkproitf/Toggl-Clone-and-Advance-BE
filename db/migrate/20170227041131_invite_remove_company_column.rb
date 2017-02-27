class InviteRemoveCompanyColumn < ActiveRecord::Migration[5.0]
  def change
      remove_column :invites, :company_id
  end
end
