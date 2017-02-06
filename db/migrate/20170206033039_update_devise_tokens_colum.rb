class UpdateDeviseTokensColum < ActiveRecord::Migration[5.0]
  def change
    change_column(:users, :tokens, :jsonb)
  end
end
