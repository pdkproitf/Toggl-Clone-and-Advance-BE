class AddExpiryColumnInInvite < ActiveRecord::Migration[5.0]
  def change
      add_column :invites, :expiry, :datetime
  end
end
