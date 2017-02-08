class ProjectCategory < ApplicationRecord
    belongs_to :project
    belongs_to :category
    has_many :project_category_users, dependent: :destroy
    has_many :users, through: :project_category_users

    def get_tracked_time
        sum = 0
        if project_category_users
            project_category_users.each do |pcu|
                sum += pcu.get_tracked_time
            end
        end
        sum
    end
end
