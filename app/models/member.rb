class Member < ApplicationRecord
    belongs_to :company
    belongs_to :user
    belongs_to :role
    has_many :projects # Create new
    has_many :joined_projects, through: :project_members, source: :projects
    has_many :project_members, dependent: :destroy
    has_many :category_members, dependent: :destroy
    has_many :assigned_categories, through: :category_members, source: :categories

    validates_uniqueness_of :company_id, scope: [:user_id, :role_id]

    # After initialization, set default values
    after_initialize :set_default_values

    def set_default_values
        # Only set if attribute IS NOT set
        self.role ||= 3 # 1: Admin, 2: PM, 3: Staff
        self.furlough_total ||= 10
    end

    def admin?
        role.name == 'Admin'
    end

    def pm?
        role.name == 'PM'
    end
end
