class ProjectMember < ApplicationRecord
  belongs_to :project
  belongs_to :member
  has_many :category_members, dependent: :destroy
  has_many :assigned_categories, through: :category_members, source: :category
  validates_uniqueness_of :project_id, scope: :member_id, if: 'project_id.present?'

  def archive
    return if is_archived == true
    category_members.each do |category_member|
      if category_member[:is_archived_by_project_member] == is_archived
        category_member.archived_by_project_member
      else
        category_member.unarchived_by_project_member
      end
    end
    update_attributes(is_archived: true)
  end

  def unarchive
    return if is_archived == false
    category_members.each do |category_member|
      if category_member[:is_archived_by_project_member] == is_archived
        category_member.unarchived_by_project_member
      else
        category_member.archived_by_project_member
      end
    end
    update_attributes(is_archived: false)
  end
end
