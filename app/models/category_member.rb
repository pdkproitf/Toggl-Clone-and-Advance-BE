class CategoryMember < ApplicationRecord
    belongs_to :category, optional: true
    belongs_to :member
    has_many :tasks, dependent: :destroy
    validates_uniqueness_of :category_id, scope: :member_id, if: 'category_id.present?'

    def tracked_time
        sum = 0
        if tasks
            tasks.each do |task|
                sum += task.tracked_time
            end
        end
        sum
    end
end
