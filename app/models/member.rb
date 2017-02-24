class Member < ApplicationRecord
    belongs_to :company
    belongs_to :user
    belongs_to :role
    has_many :projects # Create new
    has_many :joined_projects, through: :project_members, source: :projects

    # Find projects member assigned PM
    has_many :pm_project_members, -> { where is_pm: true }, class_name: 'ProjectMember'
    has_many :pm_projects, through: :pm_project_members, source: :project

    has_many :project_members, -> { where is_archived: false }, dependent: :destroy
    has_many :category_members, dependent: :destroy
    has_many :assigned_categories, through: :category_members, source: :category

    has_many :tasks, through: :category_members

    validates_uniqueness_of :company_id, scope: [:user_id, :role_id]

    # After initialization, set default values
    after_initialize :set_default_values

    def set_default_values
        # Only set if attribute IS NOT set
        self.role ||= 3 # 1: Admin, 2: PM, 3: Staff
        self.furlough_total ||= 10
    end

    def get_projects
        if role == 1 && role == 2
            # Get all projects of company
            projects = company.projects.where(is_archived: false).order('id desc')
        else
            # Get projects @current_member assigned pm
            projects = pm_projects.where(is_archived: false).order('id desc')
        end
        projects
    end

    def admin?
        role.name == 'Admin'
    end

    def pm?
        role.name == 'PM'
    end
end
