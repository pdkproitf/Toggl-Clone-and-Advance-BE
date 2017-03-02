class AddMemberReferenceToTimeoff < ActiveRecord::Migration[5.0]
  def change
      add_reference :time_offs, :sender, references: :members
      add_reference :time_offs, :approver, references: :members
  end
end
