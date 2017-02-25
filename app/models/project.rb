class Project < ApplicationRecord
    attr_accessor :name
    belongs_to :member
    belongs_to :client
    has_many :categories, dependent: :destroy
    has_many :project_members, dependent: :destroy
    has_many :members, through: :project_members

    validates :name, presence: true
    validates :client_id, presence: true
    validates :member_id, presence: true
    validates_uniqueness_of :name, scope: [:client_id, :member_id]

    def tracked_time
        sum = 0
        if categories
            categories.each do |category|
                sum += category.tracked_time
            end
        end
        sum
    end
end
