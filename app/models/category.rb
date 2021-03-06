class Category < ApplicationRecord
  belongs_to :project
  has_many :category_members, dependent: :destroy
  has_many :project_members, through: :category_members
  has_many :tasks, through: :category_members

  validates :name, presence: true, length: { minimum: 1 }
  validates_uniqueness_of :name, scope: :project_id

  def unarchived_category_members
    category_members.where(is_archived: false)
  end

  def tracked_time(begin_date = nil, end_date = nil)
    sum = 0
    unarchived_category_members.each do |category_member|
      sum += category_member.tracked_time(begin_date, end_date)
    end
    sum
  end

  def category_members_except_with(project_member_ids)
    category_members.where.not(is_archived: true, project_member_id: project_member_ids)
  end

  def archive
    return if is_archived == true
    category_members.each do |category_member|
      category_member[:is_archived] == is_archived ? category_member.archive : category_member.unarchive
    end
    update_attributes(is_archived: true)
  end

  def unarchive
    return if is_archived == false
    category_members.each do |category_member|
      category_member[:is_archived] == is_archived ? category_member.unarchive : category_member.archive
    end
    update_attributes(is_archived: false)
  end
end
