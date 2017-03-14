class Report
  # @@no_of_reports = 0
  def tracked_time
    stop_time - start_time
  end

  def initialize(who_run, begin_date, end_date, options = {})
    @who_run = who_run || nil
    @begin_date = begin_date || nil
    @end_date = end_date || nil
    @project = options[:project] || nil
    @client = options[:client] || nil
    @member_id = options[:member_id] || nil
    @working_time_per_day = who_run.company.working_time_per_day
    @working_time_per_week = who_run.company.working_time_per_week
    @begin_week = who_run.company.begin_week
  end

  def access_denied?
    if !@who_run.admin? && !@who_run.pm?
      if !@project.nil? &&
         @who_run.project_members.exists?(project_id: @project_id, is_pm: true)
        return false
      end
      true
    else
      false
    end
  end

  def project_pm?
    if !@project.nil? &&
       @who_run.project_members.exists?(project_id: @project_id, is_pm: true)
      return true
    end
    false
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
    # Report people
    {
      people: report_people,
      projects: report_projects
    }
  end

  def report_by_project
    project_options = { chart_serialized: true,
                        categories_serialized: true,
                        members_serialized: false,
                        begin_date: @begin_date, end_date: @end_date }
    return { data: project } if @project.nil?
    { data: ProjectSerializer.new(@project, project_options) }
  end

  def report_by_client; end

  def report_by_member
    member_chart
  end

  private

  # Report people
  def report_people
    person_options = { begin_date: @begin_date,
                       end_date: @end_date,
                       is_tracked_time_serialized: true }
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
    project_options = { begin_date: @begin_date,
                        end_date: @end_date,
                        members_serialized: false }
    projects = []
    @who_run.get_projects
            .where(is_archived: false)
            .order(:name).each do |project|
      projects.push(
        ProjectSerializer.new(project, project_options)
      )
    end
    projects
  end

  def member_chart
    member = Member.find(@member_id)
    member_options = { chart_serialized: true,
                       is_tracked_time_serialized: true,
                       chart_serialized: false,
                       begin_date: @begin_date, end_date: @end_date }
    MembersSerializer.new(member, member_options)
  end

  def member_project; end

  def member_category; end

  def member_overtime; end
end
