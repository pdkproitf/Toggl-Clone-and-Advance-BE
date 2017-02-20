class RemoveUserFromClients < ActiveRecord::Migration[5.0]
  def change
    remove_reference :clients, :user, foreign_key: true
  end
end
