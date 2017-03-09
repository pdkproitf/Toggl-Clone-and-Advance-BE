class CategoryMember < ApplicationRecord
  belongs_to :category, optional: true
  belongs_to :project_member
  has_many :tasks, dependent: :destroy
  validates_uniqueness_of :category_id, scope: :project_member_id, if: 'category_id.present?'

  def tracked_time(begin_date = nil, end_date = nil)
    sum = 0
    tasks.each do |task|
      sum += task.tracked_time(begin_date, end_date)
    end
    sum
  end

  def archived_by_category
    update_attributes(is_archived_by_category: true)
  end

  def archived_by_project_member
    update_attributes(is_archived_by_project_member: true)
  end

  def unarchived_by_category
    update_attributes(is_archived_by_category: false)
  end

  def unarchived_by_project_member
    update_attributes(is_archived_by_project_member: false)
  end
end
