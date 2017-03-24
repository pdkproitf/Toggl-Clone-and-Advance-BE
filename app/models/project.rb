class Project < ApplicationRecord
  belongs_to :member
  belongs_to :client
  has_many :categories, dependent: :destroy
  has_many :project_members, dependent: :destroy
  has_many :members, through: :project_members
  has_many :assigned_members, through: :categories, source: :category_members

  validates :name, presence: true
  validates :client_id, presence: true
  validates :member_id, presence: true
  validates_uniqueness_of :name, scope: [:client_id, :member_id]

  def update_info(name, client, options = {})
    self.name = name
    self.client = client
    self.background = options[:background] if options[:background].present?
    self.is_member_report = options[:is_member_report] if options[:is_member_report].present?
    save!
  end

  def update_members(members = [])
    ProjectMember.transaction do
      if members.blank?
        project_members.each(&:archive)
        return
      end

      member_ids = []
      members.each do |member|
        member_ids.push(member.id)
        existing_member = project_members.find_by(member_id: member.id)
        if existing_member.blank? # Add new member to project
          new_member = self.member.company.members.find(member.id)
          project_members.create!(member_id: new_member.id, is_pm: member.is_pm)
        else # Edit existing member of project
          existing_member[:is_pm] = member.is_pm
          existing_member.unarchive
          existing_member.save!
        end
      end
      # Archive members were added to project before but not exist in params
      members_except_with(member_ids).each(&:archive)
    end
  end

  def unarchived_members
    project_members.where(is_archived: false)
  end

  def unarchived_categories
    categories.where(is_archived: false)
  end

  def tracked_time(begin_date = nil, end_date = nil)
    sum = 0
    categories.each do |category|
      sum += category.tracked_time(begin_date, end_date)
    end
    sum
  end

  def members_except_with(member_ids)
    project_members.where.not(member_id: member_ids, is_archived: true)
  end

  def categories_except_with(category_ids)
    categories.where.not(id: category_ids, is_archived: true)
  end

  def archive
    return if is_archived == true
    categories.each do |category|
      if category[:is_archived] == is_archived
        category.archive
      else
        category.unarchive
      end
    end
    project_members.each do |project_member|
      if project_member[:is_archived] == is_archived
        project_member.archive
      else
        project_member.unarchive
      end
    end
    update_attributes(is_archived: true)
  end

  def unarchive
    return if is_archived == false
    categories.each do |category|
      if category[:is_archived] == is_archived
        category.unarchive
      else
        category.archive
      end
    end
    project_members.each do |project_member|
      if project_member[:is_archived] == is_archived
        project_member.unarchive
      else
        project_member.archive
      end
    end
    update_attributes(is_archived: false)
  end
end
