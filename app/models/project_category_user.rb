class ProjectCategoryUser < ApplicationRecord
    belongs_to :project_category, optional: true
    belongs_to :user
    has_many :tasks, dependent: :destroy

    def get_tracked_time
        sum = 0
        if tasks
            tasks.each do |task|
                sum += task.get_tracked_time
            end
        end
        sum
    end

    def test_return
        'hehe'
    end
end
