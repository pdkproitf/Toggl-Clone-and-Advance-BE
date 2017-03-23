class ProjectMember < ApplicationRecord
  belongs_to :project
  belongs_to :member
  has_many :category_members, dependent: :destroy
  has_many :assigned_categories, through: :category_members, source: :category
  validates_uniqueness_of :project_id, scope: :member_id, if: 'project_id.present?'

  def archive
    return if is_archived == true
    update_attributes(is_archived: true)
  end

  def unarchive
    return if is_archived == false
    update_attributes(is_archived: false)
  end
end
