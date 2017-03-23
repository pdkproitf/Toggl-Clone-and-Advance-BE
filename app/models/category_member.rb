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

  def archive
    return if is_archived == true
    update_attributes(is_archived: true)
  end

  def unarchive
    return if is_archived == false
    update_attributes(is_archived: false)
  end
end
