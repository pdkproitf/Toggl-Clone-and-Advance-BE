class Report
  def initialize(who_run, begin_date, end_date, options = {})
    @who_run = who_run || nil
    @begin_date = begin_date || nil
    @end_date = end_date || nil
    @client = options[:client] || nil
    @member = options[:member] || nil
    @working_time_per_day = who_run.company.working_time_per_day
    @working_time_per_week = who_run.company.working_time_per_week
    @begin_week = who_run.company.begin_week
  end

  def overtime?(date)
    date_diff = date.wday - @begin_week
    date_diff += 7 if date_diff < 0
    begin_week_date = date - date_diff
    (begin_week_date..begin_week_date + 6).each do |week_date|
      puts week_date
    end
  end

  def report_by_time
    {
      people: report_people,
      projects: report_projects
    }
  end

  def report_by_project
    projects = []
    project_options = { chart_serialized: true,
                        categories_serialized: true,
                        members_serialized: false,
                        begin_date: @begin_date, end_date: @end_date }
    @who_run.get_projects.where(is_archived: false).each do |project|
      projects.push(ProjectSerializer.new(project, project_options))
    end
    projects
  end

  def report_by_client; end

  def report_by_member
    return nil if @member.nil?
    member_options = { begin_date: @begin_date, end_date: @end_date,
                       tracked_time_serialized: true }
    result = {}
    result.merge!(MembersSerializer.new(@member, member_options))
    result[:projects] = member_projects
    result[:tasks] = member_tasks
    result[:overtime] = 'Overtime'
    result
  end

  private

  # Report people
  def report_people
    person_options = { begin_date: @begin_date,
                       end_date: @end_date,
                       tracked_time_serialized: true }
    if @who_run.member?
      # As staff, return only data of the staff
      return Array(MembersSerializer.new(@who_run, person_options))
    else
      # As Admin and Super PM, return data of all member in company
      people = []
      @who_run.company.members.each do |member|
        people.push(MembersSerializer.new(member, person_options))
      end
      return people
    end
  end

  # Report projects
  def report_projects
    project_options = { begin_date: @begin_date, end_date: @end_date,
                        members_serialized: false }
    projects = []
    @who_run.get_projects.where(is_archived: false)
            .order(:name).each do |project|
      projects.push(
        ProjectSerializer.new(project, project_options)
      )
    end
    projects
  end

  def member_projects
    if @who_run.member?
      who_run_projects = @who_run.joined_projects.where(is_archived: false)
    else
      who_run_projects = @who_run.get_projects.where(is_archived: false)
    end
    member_joined_categories = @member
                               .assigned_categories
                               .where(projects: { id: who_run_projects.ids })
    result = []
    member_joined_categories.each do |assigned_category|
      item = result.find { |h| h[:id] == assigned_category[:project_id] }
      unless item
        item = {
          id: assigned_category[:project_id],
          name: assigned_category[:project_name]
        }
        item[:background] = assigned_category[:background]
        item[:client] = {
          id: assigned_category[:client_id],
          name: assigned_category[:client_name]
        }
        item[:category] = []
        item[:chart] = {}
        count = 0
        (@begin_date..@end_date).each do |date|
          item[:chart][date] = {}
          item[:chart][date][:billable] = 0
          item[:chart][date][:unbillable] = 0
          break if item[:chart].size == 366
        end
        result.push(item)
      end
      item[:category].push(
        name: assigned_category[:category_name],
        category_member_id: assigned_category[:category_member_id],
        tracked_time: assigned_category.tracked_time(@begin_date, @end_date)
      )
      (@begin_date..@end_date).each do |date|
        if assigned_category.category.is_billable == true
          item[:chart][date][:billable] += assigned_category
                                           .tracked_time(date, date)
        else
          item[:chart][date][:unbillable] += assigned_category
                                             .tracked_time(date, date)
        end
      end
    end
    result
  end

  def member_tasks
    tasks = []
    @member.tasks.where.not(category_members: { category_id: nil })
           .where(category_members: { is_archived_by_category: false })
           .where(category_members: { is_archived_by_project_member: false })
           .each do |task|
      tasks.push(TaskTestSerializer.new(task))
    end
    tasks
  end

  def member_overtime; end
end
