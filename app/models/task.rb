class Task < ApplicationRecord
  belongs_to :category_member
  has_many :timers, dependent: :destroy
  # validates :name, length: { minimum: 1 }, allow_nil: true
  validates_uniqueness_of :name, scope: :category_member_id, if: 'name.present?'

  def tracked_time(begin_date = nil, end_date = nil)
    sum = 0
    if !begin_date.nil? && !end_date.nil?
      timer_list = timers.where('start_time >= ? AND start_time < ?',
                                begin_date, end_date + 1)
    else
      timer_list = timers
    end
    timer_list.each do |timer|
      sum += timer.tracked_time
    end
    sum
  end
end
