class Category < ApplicationRecord
  belongs_to :project
  has_many :category_members, dependent: :destroy
  has_many :members, through: :category_members
  validates :name, presence: true, length: { minimum: 1 }
  validates_uniqueness_of :name, scope: :project_id

  def tracked_time(begin_date, end_date)
    sum = 0
    category_members.each do |category_member|
      sum += category_member.tracked_time(begin_date, end_date)
    end
    sum
  end

  def category_members_except_with(member_ids)
    category_members.where.not(member_id: member_ids, is_archived: true)
  end

  def archive
    update_attributes(is_archived: true)
  end

  def unarchive
    update_attributes(is_archived: false)
  end
end
