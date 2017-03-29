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
      if members.empty?
        project_members.each(&:archive)
        return
      end
      # member present
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

  def update_categories(cats = [])
    Category.transaction do
      if cats.empty?
        categories.each(&:archive)
        return
      end
      # Categories present
      category_ids = []
      cats.each do |category|
        category_ids.push(category.id)
        if category.id.nil? # Add new category
          new_category = categories.new(name: category.name, is_billable: category.is_billable)
          # Add members to new category
          category.member_ids.each do |member_id|
            project_member = project_members.find(member_id)
            new_category.category_members.new(project_member_id: project_member.id)
          end
          save!
        else # Unarchive and change info of old category existing in params
          existing_category = categories.find(category.id)
          existing_category[:name] = category.name
          existing_category[:is_billable] = category.is_billable
          existing_category.unarchive
          # Update members of existing category
          project_member_ids = []
          category.member_ids.each do |member_id|
            # Check member whether added to project or not
            project_member = project_members.find_by!(member_id: member_id, is_archived: false)
            project_member_ids.push(project_member.id)
            # Check member whether assigned to category or not
            category_member = existing_category.category_members.find_by(project_member_id: project_member.id)
            if category_member.nil? # Add new member
              existing_category.category_members.new(project_member_id: project_member.id)
            elsif category_member.is_archived
              category_member.unarchive
            end
          end
          existing_category.save!
          # Archive members not in params
          existing_category.category_members_except_with(project_member_ids).each(&:archive)
        end # End of if category.id.nil?
      end # End of categories each
      # Archive old category not existing in params
      categories_except_with(category_ids).each(&:archive)
    end # End of Category transaction
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
      category[:is_archived] == is_archived ? category.archive : category.unarchive
    end
    project_members.each do |project_member|
      project_member[:is_archived] == is_archived ? project_member.archive : project_member.unarchive
    end
    update_attributes(is_archived: true)
  end

  def unarchive
    return if is_archived == false
    categories.each do |category|
      category[:is_archived] == is_archived ? category.unarchive : category.archive
    end
    project_members.each do |project_member|
      project_member[:is_archived] == is_archived ? project_member.unarchive : project_member.archive
    end
    update_attributes(is_archived: false)
  end

  def day_chart(begin_date, end_date)
    chart = []
    (begin_date..end_date).each do |date|
      item = {}
      item[date] = category_tracked_time(date, date)
      chart.push(item)
    end
    chart
  end

  def month_chart(begin_date, end_date)
    chart = []
    begin_date_month = begin_date.strftime('%Y-%m')
    end_date_month = end_date.strftime('%Y-%m')
    next_end_date_month = (Date.new(end_date.year, end_date.month, -1) + 1).strftime('%Y-%m')
    month = begin_date_month
    month_begin_date = begin_date
    month_end_date = Date.new(begin_date.year, begin_date.month, -1)

    until month == next_end_date_month
      month == begin_date_month ? month_begin_date = begin_date : month_begin_date = month_end_date + 1
      month == end_date_month ? month_end_date = end_date : month_end_date = Date.new(month_begin_date.year, month_begin_date.month, -1)

      columns = {}
      columns[month] = category_tracked_time(month_begin_date, month_end_date)
      chart.push(columns)

      month = (Date.new(month_end_date.year, month_end_date.month, -1) + 1).strftime('%Y-%m')
    end

    chart
  end

  def year_chart(begin_date, end_date)
    chart = []
    year = begin_date.year
    until year == end_date.year + 1
      year == begin_date.year ? year_begin_date = begin_date : year_begin_date = Date.new(year, 0o1, 0o1)
      year == end_date.year ? year_end_date = end_date : year_end_date = Date.new(year, 12, 31)

      columns = {}
      columns[year_begin_date.year] = category_tracked_time(year_begin_date, year_end_date)
      chart.push(columns)

      year += 1
    end

    chart
  end

  def category_tracked_time(begin_date, end_date)
    billable_total = 0
    unbillable_total = 0
    object.categories.each do |category|
      tracked_time = category.tracked_time(begin_date, end_date)
      category.is_billable ? billable_total += tracked_time : unbillable_total += tracked_time
    end
    { billable: billable_total, unbillable: unbillable_total }
  end
end
