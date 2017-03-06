class Project < ApplicationRecord
  belongs_to :member
  belongs_to :client
  has_many :categories, dependent: :destroy
  has_many :project_members, dependent: :destroy
  has_many :members, through: :project_members
  has_many :assigned_members, through: :categories, source: :category_members

  validates :name, presence: true
  validates :client_id, presence: true
  validates :member_id, presence: true
  validates_uniqueness_of :name, scope: [:client_id, :member_id]

  def get_tracked_time
    sum = 0
    if categories
      categories.each do |category|
        sum += category.get_tracked_time
      end
    end
    sum
  end

  def members_except_with(member_ids)
    project_members.where.not(member_id: member_ids, is_archived: true)
  end

  def archive
    update_attributes(is_archived: true)
  end

  def unarchive
    update_attributes(is_archived: false)
  end
end
