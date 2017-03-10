class Report
  # @@no_of_reports = 0
  def initialize(who_run, begin_date, end_date, options = {})
    @who_run = who_run || nil
    @begin_date = begin_date || nil
    @end_date = end_date || nil
    @project = options[:project] || nil
    @client = options[:client] || nil
    @member = options[:member] || nil
    @working_time_per_day = who_run.company.working_time_per_day
    @working_time_per_week = who_run.company.working_time_per_week
    @begin_week = who_run.company.begin_week
  end

  def access_denied?
    if !@who_run.admin? && !@who_run.pm?
      if !@project.nil? &&
         @who_run.project_members.exists?(project_id: @project.id, is_pm: true)
        return false
      end
      true
    else
      false
    end
  end

  def report_by_time; end

  def report_by_project; end

  def report_by_client; end

  def report_by_member; end
end
