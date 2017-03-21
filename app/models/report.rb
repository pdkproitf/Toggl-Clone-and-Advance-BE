class Report
  def initialize(who_run, begin_date, end_date, options = {})
    @who_run = who_run
    @begin_date = begin_date
    @end_date = end_date
    @client = options[:client] || nil
    @member = options[:member] || nil
    @working_time_per_day = who_run.company.working_time_per_day
    @working_time_per_week = who_run.company.working_time_per_week
    @begin_week = who_run.company.begin_week
    @overtime_type = { holiday: 'Holiday', weekend: 'Weekend', normal: 'Normal' }
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
    result[:overtime] = member_overtime
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
    task_options = { begin_date: @begin_date, end_date: @end_date }
    @member.perfect_tasks.each do |task|
      customized_task = TaskTestSerializer.new(task, task_options)
      tasks.push(customized_task) if customized_task.tracked_time > 0
    end
    tasks
  end

  def member_overtime
    day_working_times = day_working_time
    week = {}
    week_overtime = {}
    timers = []
    days = {}
    overtime_timers.each do |timer|
      week_date = timer.start_time.to_date
      week_first_day = week_first_day(week_date)

      if week[week_first_day(week_date)].nil?
        week[week_first_day] = { overtime: 0, holidays: nil }
        week_overtime = {}
        # Check week of start_time of timer overtime or not
        if week_of_date_overtime(week_first_day) > 0
          week_of_date_overtime = week_of_date_overtime(week_first_day)
          week[week_first_day][:overtime] = week_of_date_overtime
          week[week_first_day][:holidays] = holidays_in_week_of_date(week_first_day)
          week_overtime[week_first_day] = week_of_date_overtime
        end
      end

      days[week_date] = 0 if days[week_date].nil?
      days[week_date] += timer.tracked_time

      # Check overtime of that date
      options = {}
      if week[week_first_day][:overtime] > 0 && week_overtime[week_first_day] > 0
        if week[week_first_day][:holidays].include?(week_date)
          options[:overtime_type] = @overtime_type[:holiday]
          week_overtime[week_first_day] -= timer.tracked_time
        elsif week_date.wday == 0 || week_date.wday == 6
          options[:overtime_type] = @overtime_type[:weekend]
          week_overtime[week_first_day] -= timer.tracked_time
        elsif day_working_times[week_date] > @working_time_per_day * 3600
          day_overtime = days[week_date] - @working_time_per_day * 3600
          if day_overtime > 0
            if (days[week_date] - timer.tracked_time) < @working_time_per_day * 3600
              options[:overtime_type] = @overtime_type[:normal]
              options[:start_time_overtime] = timer.stop_time - day_overtime
              week_overtime[week_first_day] -= day_overtime
            else
              options[:overtime_type] = @overtime_type[:normal]
              week_overtime[week_first_day] -= timer.tracked_time
            end
          end
        end
      end
      next unless options[:overtime_type].present?
      timers.push(TestOvertimeTimerSerializer.new(timer, options))
      p week_overtime[week_first_day]
      p week[week_first_day]
    end
    timers
  end

  def day_working_time
    day_overtime = {}
    overtime_timers.each do |timer|
      week_date = timer.start_time.to_date
      day_overtime[week_date] = 0 if day_overtime[week_date].nil?
      day_overtime[week_date] += timer.tracked_time
    end
    day_overtime
  end

  def overtime_timers
    @member.timers.where(category_members: { id: member_joined_categories.ids })
           .where('start_time >= ? AND start_time < ?', @begin_date, @end_date + 1)
           .order(:start_time)
  end

  def member_joined_categories
    if @who_run.member? && @who_run.id == @member.id
      who_run_projects = @who_run.joined_projects.where(is_archived: false)
    else
      who_run_projects = @who_run.get_projects.where(is_archived: false)
    end
    @member.assigned_categories
           .where(projects: { id: who_run_projects.ids })
  end

  def week_of_date_overtime(date)
    holiday_hour_off_in_week = holiday_hour_off_in_week(date)
    working_time_per_week = @working_time_per_week - holiday_hour_off_in_week
    overtime = week_working_time(date) - working_time_per_week * 3600
    return 0 if overtime <= 0
    overtime
  end

  def week_first_day(week_day)
    day_diff = week_day.wday - @begin_week
    day_diff += 7 if day_diff < 0
    week_day - day_diff
  end

  def week_working_time(week_day)
    week_first_day = week_first_day(week_day)
    @member.tracked_time(week_first_day, week_first_day + 6)
  end

  def holidays_in_week_of_date(date)
    week_first_day = week_first_day(date)
    @who_run.company.holidays
    holidays = @who_run.company.holidays
    holidays_in_week_of_date = []
    (week_first_day..week_first_day + 6).each do |date_in_week|
      holidays.each do |holiday|
        if date_in_week >= holiday.begin_date &&
           date_in_week <= holiday.end_date
          holidays_in_week_of_date.push(date_in_week)
          break
        end
      end
    end
    holidays_in_week_of_date
  end

  def holiday_hour_off_in_week(date)
    not_weekend_holidays = 0
    holidays_in_week_of_date(date).each do |holiday|
      not_weekend_holidays += 1 if holiday.wday != 0 && holiday.wday != 6
    end
    not_weekend_holidays * @working_time_per_day
  end
end
