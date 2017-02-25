class Category < ApplicationRecord
    belongs_to :project
    has_many :category_members, dependent: :destroy
    has_many :members, through: :category_members
    validates :name, presence: true, length: { minimum: 1 }
    validates_uniqueness_of :name, scope: :project_id

    def tracked_time
        sum = 0
        if category_members
            category_members.each do |category_member|
                sum += category_member.tracked_time
            end
        end
        sum
    end
end
