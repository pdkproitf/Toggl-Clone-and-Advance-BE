class Task < ApplicationRecord
    belongs_to :category_member
    has_many :timers, dependent: :destroy
    validates :name, length: { minimum: 1 }, allow_nil: true
    validates_uniqueness_of :name, scope: :category_member_id, if: 'name.present?'

    def get_tracked_time
        sum = 0
        if timers
            timers.each do |timer|
                sum += timer.get_tracked_time
            end
        end
        sum
    end
end
