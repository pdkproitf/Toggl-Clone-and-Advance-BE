class Member < ApplicationRecord
  belongs_to :company
  belongs_to :user
  belongs_to :role
  has_many :projects, dependent: :destroy # Create new
  has_many :joined_projects, through: :project_members, source: :projects

  # Find projects member assigned PM
  has_many :pm_project_members, -> { where is_pm: true }, class_name: 'ProjectMember'
  has_many :pm_projects, through: :pm_project_members, source: :project

  has_many :project_members, dependent: :destroy
  has_many :category_members, through: :project_members

  has_many :tasks, through: :category_members
  has_many :timers, through: :tasks

  has_many :sent_invites, class_name: 'Invite', foreign_key: 'sender_id'

  has_many :off_requests, class_name: 'TimeOff', foreign_key: 'sender_id'
  has_many :off_approvers, class_name: 'TimeOff', foreign_key: 'approver_id'

  validates_uniqueness_of :company_id, scope: [:user_id, :role_id]

  # After initialization, set default values
  after_initialize :set_default_values

  def set_default_values
    # Only set if attribute IS NOT set
    self.role ||= 3 # 1: Admin, 2: PM, 3: Member
    self.furlough_total ||= 10
  end

  # Get all projects that member manage regardless to archive or not
  def get_projects
    if admin? || pm?
      # Get all projects of company
      return company.projects
    end
    # Get projects that member's role is project manager
    pm_projects
  end

  def admin?
    role.name == 'Admin'
  end

  def pm?
    role.name == 'PM'
  end

  def member?
    role.name == 'Member'
  end
end
