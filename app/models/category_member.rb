class CategoryMember < ApplicationRecord
  belongs_to :category, optional: true
  belongs_to :member
  has_many :tasks, dependent: :destroy
  validates_uniqueness_of :category_id, scope: :member_id, if: 'category_id.present?'

  def tracked_time(begin_date, end_date)
    sum = 0
    tasks.each do |task|
      sum += task.tracked_time(begin_date, end_date)
    end
    sum
  end

  def archive
    update_attributes(is_archived: true)
  end

  def unarchive
    update_attributes(is_archived: false)
  end
end
