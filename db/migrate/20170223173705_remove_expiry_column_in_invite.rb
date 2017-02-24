class RemoveExpiryColumnInInvite < ActiveRecord::Migration[5.0]
  def change
      remove_column :invites, :expiry
  end
end
