class SendReportJob < ApplicationJob
  queue_as :default

  def perform(args)
    puts 'Send report Oh yeah!'
    company = Company.find(args['company_id'])
    # active_users = company.active_users

    company.active_members.each do |member|
      puts member.user.email
      # data = report_data(company.admin, member)
      puts data
      # ReportMailer.sample_email(member.user, company, data).deliver_now
    end
  end

  def report_data(reporter, member)
    report = ReportHelper::Report.new(reporter, '2017-03-27'.to_date, '2017-04-01'.to_date, member: member)
    report.report_member_tasks
  end
end
