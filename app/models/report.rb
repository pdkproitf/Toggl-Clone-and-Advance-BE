class Report
  # @@no_of_reports = 0
  def initialize(who_run, begin_date, end_date, options = {})
    @who_run = who_run || nil
    @begin_date = begin_date || nil
    @end_date = end_date || nil
    @project_id = options[:project_id] || nil
    @client = options[:client] || nil
    @member = options[:member] || nil
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

  def report_by_time
    if @who_run.admin? || @who_run.pm?
      # Report people
      person_options = { begin_date: @begin_date,
                         end_date: @end_date,
                         is_tracked_time_serialized: true }
      people = []
      @who_run.company.members.each do |member|
        people.push(MembersSerializer.new(member, person_options))
      end

      # Report projects
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

      # Return result
      { data: {
        people: people,
        projects: projects
      } }
    end
   end

  def report_by_project
    project = @who_run.get_projects.find_by(id: @project_id)
    project_options = { chart_serialized: true,
                        categories_serialized: true,
                        members_serialized: false,
                        begin_date: @begin_date, end_date: @end_date }
    return { data: project } if project.nil?
    { data: ProjectSerializer.new(project, project_options) }
  end

  def report_by_client; end

  def report_by_member; end
end
