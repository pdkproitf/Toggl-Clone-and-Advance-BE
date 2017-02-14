class Project < ApplicationRecord
    validates :name, presence: true
    belongs_to :user
    belongs_to :client
    has_many :project_categories, dependent: :destroy
    has_many :categories, through: :project_categories
    has_many :project_user_roles, dependent: :destroy
    has_many :users, through: :project_user_roles
    has_many :roles, through: :project_user_roles

    def get_tracked_time
        sum = 0
        if project_categories
            project_categories.each do |pc|
                sum += pc.get_tracked_time
            end
        end
        sum
    end
end
