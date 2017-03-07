class AddDefaultForIsMemberReport < ActiveRecord::Migration[5.0]
  def change
    change_column_default :projects, :is_member_report, false
  end
end
