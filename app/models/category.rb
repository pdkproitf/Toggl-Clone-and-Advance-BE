class Category < ApplicationRecord
    belongs_to :project
    has_many :category_members, dependent: :destroy
    has_many :members, through: :category_members
    validates :name, presence: true, length: { minimum: 1 }
    validates_uniqueness_of :name, scope: :project_id

    def get_tracked_time
        sum = 0
        if category_members
            category_members.each do |category_member|
                sum += category_member.get_tracked_time
            end
        end
        sum
    end

    def archive
        update_attributes(is_archived: true)
        # Archive all category members
        category_members.each(&:archive) if category_members
    end

    def unarchive
        update_attributes(is_archived: false)
        # Unarchive all category members
        category_members.each(&:unarchive) if category_members
    end
end
