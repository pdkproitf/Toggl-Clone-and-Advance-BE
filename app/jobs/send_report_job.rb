class SendReportJob < ApplicationJob
  queue_as :default

  def perform
    puts 'Send report Oh yeah!'
    today_wday = Date.today.wday
    today_wday = 1 # For test
    companies = Company.where(begin_week: today_wday)
    start_date = '2017-03-27'.to_date
    end_date = start_date + 6

    users = User.all
    users.each do |user|
      members = user.members.where(company_id: companies.ids)
      data = []
      members.each do |member|
        company = member.company
        reporter = company.admin
        report_data = report_data(reporter, member, start_date, end_date)
        custom_report_data = custom_report_data(report_data)
        custom_report_data[:company] = company
        data.push(custom_report_data)
      end
      ReportMailer.sample_email(user, data, start_date, end_date).deliver_now
    end
  end

  def report_data(reporter, member, start_date, end_date)
    report = ReportHelper::Report.new(reporter, start_date, end_date, member: member)
    report.report_member_tasks
  end

  def custom_report_data(report_data)
    tracked_time_total = 0
    projects = []
    report_data.to_a.each do |task|
      tracked_time_total += task[:tracked_time]
      project = projects.find { |h| h[:id] == task[:project_id] }
      if project.blank?
        project = { id: task[:project_id], name: task[:project_name] }
        project[:client] = task[:client]
        project[:background] = task[:background]
        project[:tracked_time] = 0
        project[:categories] = []
        projects.push(project)
      end
      project[:tracked_time] += task[:tracked_time]
      category = project[:categories].find { |h| h[:category_name] == task[:category_name] }
      if category.blank?
        category = { category_name: task[:category_name] }
        category[:tasks] = []
        category[:tracked_time] = 0
        project[:categories].push(category)
      end
      category[:tasks].push(id: task[:id], name: task[:name], tracked_time: task[:tracked_time])
      category[:tracked_time] += task[:tracked_time]
    end
    { tracked_time_total: tracked_time_total, projects: projects }
  end
end
