class ChangeRelationAmongMemberProjectCategory < ActiveRecord::Migration[5.0]
  def change
    remove_reference :category_members, :member, foreign_key: true
    add_reference :category_members, :project_member, foreign_key: true
  end
end
