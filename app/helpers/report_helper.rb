module ReportHelper
  class Report
    include Datetimes::Week
    include HolidayHelper

    def initialize(reporter, begin_date, end_date, options = {})
      @reporter = reporter
      @begin_date = begin_date.to_date
      @end_date = end_date.to_date
      @client = options[:client] || nil
      @member = options[:member] || nil
      @chart_limit = 366
      @working_time_per_day = reporter.company.working_time_per_day
      @working_time_per_week = reporter.company.working_time_per_week
      @begin_week = reporter.company.begin_week
      @overtime_type = { holiday: 'Holiday', weekend: 'Weekend', normal: 'Normal' }
    end

    def report_by_time
      { people: report_people, projects: report_projects }
    end

    def report_by_project
      projects = []
      project_options = { chart_serialized: true, categories_serialized: true,
                          members_serialized: false, begin_date: @begin_date, end_date: @end_date }
      @reporter.get_projects.where(is_archived: false).each do |project|
        projects.push(ProjectSerializer.new(project, project_options))
      end
      projects
    end

    def report_by_client; end

    def report_by_member
      return nil if @member.nil?
      member_options = { begin_date: @begin_date, end_date: @end_date, tracked_time_serialized: true }
      result = {}
      result.merge!(MembersSerializer.new(@member, member_options))
      result[:projects] = member_projects
      result[:tasks] = member_tasks
      result[:overtime] = member_overtime(@member)
      result
    end

    # private

    # Report people
    def report_people
      person_options = { begin_date: @begin_date, end_date: @end_date, tracked_time_serialized: true }
      # As staff, return only data of the staff else As Admin and Super PM, return data of all member in company
      @reporter.member? ? members = Array(@reporter) : members = @reporter.company.members
      people = []
      members.each do |member|
        person = {}
        person.merge!(MembersSerializer.new(member, person_options))
        member_overtime(member).present? ? person[:overtime] = true : person[:overtime] = false
        # person[:overtime] = true
        people.push(person)
      end
      people
    end

    # Report projects
    def report_projects
      project_options = { begin_date: @begin_date, end_date: @end_date, members_serialized: false }
      projects = []
      @reporter.get_projects.where(is_archived: false) .order(:name).each do |project|
        projects.push(ProjectSerializer.new(project, project_options))
      end
      projects
    end

    def member_projects
      result = []
      member_joined_categories(@member).each do |assigned_category|
        item = result.find { |h| h[:id] == assigned_category[:project_id] }
        unless item
          item = { id: assigned_category[:project_id], name: assigned_category[:project_name] }
          item[:background] = assigned_category[:background]
          item[:client] = { id: assigned_category[:client_id], name: assigned_category[:client_name] }
          item[:category] = []
          item[:chart] = {}
          count = 0
          (@begin_date..@end_date).take(@chart_limit).each do |date|
            item[:chart][date] = {}
            item[:chart][date][:billable] = 0
            item[:chart][date][:unbillable] = 0
          end
          result.push(item)
        end
        item[:category].push(
          name: assigned_category[:category_name],
          category_member_id: assigned_category[:category_member_id],
          tracked_time: assigned_category.tracked_time(@begin_date, @end_date)
        )
        (@begin_date..@end_date).take(@chart_limit).each do |date|
          if assigned_category.category.is_billable == true
            item[:chart][date][:billable] += assigned_category.tracked_time(date, date)
          else
            item[:chart][date][:unbillable] += assigned_category.tracked_time(date, date)
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

    def member_overtime(member)
      weeks = {} # Include information of weeks - working_time, overtime and holidays
      timers = [] # Overtime timers
      normal_timers = [] # Include the normal timers (not weekend or holiday)
      overtime_timers(member).each do |timer|
        week_date = timer.start_time.to_date
        # A week is identified by the first day of week
        week_start_date = week_start_date(week_date, @begin_week)

        if weeks[week_start_date].blank? # Create info for new week
          # Get all holidays in week
          holidays = holidays_in_week(@reporter.company, week_date, @begin_week)
          holidays_not_weekend = holidays.select { |holiday| holiday.wday != 0 && holiday.wday != 6 }
          # Calculate working time that has to do in week
          week_working_hour = @working_time_per_week - holidays_not_weekend.length * @working_time_per_day
          # Start to create week's info
          weeks[week_start_date] = { working_time: week_working_hour * 3600 }
          week_overtime = week_working_time(week_start_date, member) - weeks[week_start_date][:working_time]
          weeks[week_start_date][:overtime] = week_overtime
          weeks[week_start_date][:overtime_temp] = week_overtime
          weeks[week_start_date][:holidays] = holidays
        end

        # If week has no overtime, then skip
        next unless weeks[week_start_date][:overtime] > 0
        options = {}
        if weeks[week_start_date][:holidays].include?(week_date) # Overtime in holidays
          options[:overtime_type] = @overtime_type[:holiday]
          weeks[week_start_date][:overtime_temp] -= timer.tracked_time
        elsif week_date.wday == 0 || week_date.wday == 6 # Overtime in weekend
          options[:overtime_type] = @overtime_type[:weekend]
          weeks[week_start_date][:overtime_temp] -= timer.tracked_time
        else # If week_date is a normal day
          normal_timers.push(timer)
        end
        next unless options[:overtime_type].present?
        timers.push(TimerSerializer.new(timer, options).as_json)
      end

      # Calculate overtime for normal days
      day_time_totals = {}
      normal_timers.each do |timer|
        week_date = timer.start_time.to_date
        week_start_date = week_start_date(week_date, @begin_week)

        day_time_totals[week_date] = 0 if day_time_totals[week_date].nil?
        day_time_totals[week_date] += timer.tracked_time
        day_overtime = day_time_totals[week_date] - @working_time_per_day * 3600
        options = {}
        if weeks[week_start_date][:overtime_temp] > 0 && day_overtime > 0
          if (day_time_totals[week_date] - timer.tracked_time) < @working_time_per_day * 3600
            options[:overtime_type] = @overtime_type[:normal]
            options[:start_time_overtime] = timer.stop_time - day_overtime
            weeks[week_start_date][:overtime_temp] -= day_overtime
          else
            options[:overtime_type] = @overtime_type[:normal]
            weeks[week_start_date][:overtime_temp] -= timer.tracked_time
          end
        end
        next unless options[:overtime_type].present?
        timers.push(TimerSerializer.new(timer, options).as_json)
      end
      # Return result order by start_time asc
      timers.sort_by! { |hsh| hsh[:start_time] }
    end

    # ============================ GET TIMER ===================================
    def overtime_timers(member)
      member.timers
            .where(category_members: { id: member_joined_categories(member).ids })
            .where('start_time >= ? AND start_time < ?', @begin_date, @end_date + 1)
    end

    def member_joined_categories(member)
      if @reporter.member? && @reporter.id == member.id
        reporter_projects = @reporter.joined_projects.where(is_archived: false)
      else
        reporter_projects = @reporter.get_projects.where(is_archived: false)
      end
      member.assigned_categories.where(projects: { id: reporter_projects.ids })
    end
    # =========================== GET TIMER END ================================

    def week_working_time(week_start_date, member)
      member.tracked_time(week_start_date, week_start_date + 6)
    end
  end
end
