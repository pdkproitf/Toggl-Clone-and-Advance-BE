class Member < ApplicationRecord
    belongs_to :company
    belongs_to :user
    has_many :projects # Create new
    has_many :joined_projects, through: :project_members, source: :projects
    has_many :project_members, dependent: :destroy
    has_many :project_category_members, dependent: :destroy
    has_many :joined_project_categories, through: :project_category_members, source: :project_categories

    validates_uniqueness_of :company_id, scope: [:user_id]

    # After initialization, set default values
    after_initialize :set_default_values

    def set_default_values
        # Only set if attribute IS NOT set
        self.role ||= 3
        self.furlough_total ||= 10
    end
end
