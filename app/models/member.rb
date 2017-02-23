class Member < ApplicationRecord
    belongs_to :company
    belongs_to :user
    has_many :projects, -> { where is_archived: false } # Create new
    has_many :joined_projects, through: :project_members, source: :projects

    # Find projects member assigned PM
    has_many :pm_project_members, -> { where is_pm: true }, class_name: 'ProjectMember'
    has_many :pm_projects, through: :pm_project_members, source: :project

    has_many :project_members, -> { where is_archived: false }, dependent: :destroy
    has_many :category_members, dependent: :destroy
    has_many :assigned_categories, through: :category_members, source: :category

    validates_uniqueness_of :company_id, scope: [:user_id]

    # After initialization, set default values
    after_initialize :set_default_values

    def set_default_values
        # Only set if attribute IS NOT set
        self.role ||= 3 # 1: Admin, 2: PM, 3: Staff
        self.furlough_total ||= 10
    end
end
