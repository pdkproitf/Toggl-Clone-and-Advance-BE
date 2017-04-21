# Preview all emails at http://localhost:3000/rails/mailers/report_mailer
class ReportMailerPreview < ActionMailer::Preview
  def sample_mail_preview
    company = Company.find(4)
    member = Member.first
    custom_report_data = custom_report_data(report_data(company.admin, member))
    ReportMailer.sample_email(User.find(1), company, custom_report_data)
  end

  def report_data(reporter, member)
    report = ReportHelper::Report.new(reporter, '2017-03-27'.to_date, '2017-04-01'.to_date, member: member)
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
