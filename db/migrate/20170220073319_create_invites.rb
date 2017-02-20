class CreateInvites < ActiveRecord::Migration[5.0]
  def change
    create_table :invites do |t|
      t.string :email
      t.references :company, foreign_key: true
      t.integer :sender_id
      t.integer :recipient_id
      t.string :token
      t.integer :expiry
      t.boolean :accepted

      t.timestamps
    end
  end
end
