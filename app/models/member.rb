class Member < ApplicationRecord
  belongs_to :company
  belongs_to :user
  belongs_to :role
  has_many :projects, dependent: :destroy # Create new
  has_many :joined_projects, through: :project_members, source: :project

  # Find projects member assigned PM
  has_many :pm_project_members, -> { where is_pm: true, is_archived: false }, class_name: 'ProjectMember'
  has_many :pm_projects, through: :pm_project_members, source: :project

  has_many :project_members, -> { where is_archived: false }, dependent: :destroy
  has_many :category_members, -> { where is_archived: false }, through: :project_members

  has_many :tasks, through: :category_members
  has_many :timers, through: :tasks

  has_many :sent_invites, class_name: 'Invite', foreign_key: 'sender_id'

  has_many :off_requests, class_name: 'TimeOff', foreign_key: 'sender_id'
  has_many :off_approvers, class_name: 'TimeOff', foreign_key: 'approver_id'

  has_many :jobs_members
  has_many :jobs, through: :jobs_members

  validates_uniqueness_of :company_id, scope: [:user_id, :role_id]
  validates :day_offed, :numericality => { :greater_than => 0 }
  validates :total_day_off, :numericality => { :greater_than => 0 }

  # default_scope ->{ where(is_archived: false) }

  # After initialization, set default values
  after_initialize :set_default_values

  # Get all unarchived projects that member manage
  def get_projects
    admin? || pm? ? company.projects.where(is_archived: false) : pm_projects.where(is_archived: false)
  end

  def admin?
    actived? && (role.name == 'Admin')
  end

  def pm?
    actived? && (role.name == 'PM')
  end

  def member?
    actived? && (role.name == 'Member')
  end

  # check is member manager role
  def manager?
    actived? && (admin? || pm?)
  end

  def actived?
    !is_archived
  end

  def joined_unarchived_projects
    joined_projects.where(is_archived: false)
  end

  # Get all categories that member assigned
  def assigned_categories
    category_members
      .where(project_members: { is_archived: false })
      .where.not(category_id: nil, is_archived: true)
      .joins(category: { project: :client })
      .select('category_members.id')
      .select('projects.id as project_id', 'projects.name as project_name', 'projects.background')
      .select('clients.id as client_id', 'clients.name as client_name')
      .select('categories.id as category_id', 'categories.name as category_name')
      .select('category_members.id as category_member_id')
      .order('projects.id desc', 'categories.id asc')
  end

  def perfect_tasks
    tasks.where(project_members: { is_archived: false })
         .where.not(category_members: { category_id: nil })
         .where(category_members: { is_archived: false })
  end

  def get_timers(from_day, to_day)
    timers.where(category_members: { is_archived: false })
          .where('timers.start_time >= ? AND timers.start_time < ?', from_day, to_day + 1)
          .order('start_time desc')
  end

  def tracked_time(begin_date = nil, end_date = nil)
    sum = 0
    assigned_categories.each do |category_member|
      sum += category_member.tracked_time(begin_date, end_date)
    end
    sum
  end

  def new_fake_task(name = '')
    project_member = project_members.create!
    category_member = project_member.category_members.create!
    task = category_member.tasks.create!(name: name)
  end

  def create_job(job_name)
    job = Job.find_or_create_by(name: job_name)
    company_job = company.company_jobs.find_or_create_by(job_id: job.id)
    company_job.jobs_members.create!(member_id: id)
  end

    private
    def set_default_values # Only set if attribute IS NOT set
        self.role ||= 3 # 1: Admin, 2: PM, 3: Member
        self.total_day_off = ((Date.today.end_of_year.to_time - Date.today.to_time) / 1.month).to_i
    end
end
