# Preview all emails at http://localhost:3000/rails/mailers/report_mailer
class ReportMailerPreview < ActionMailer::Preview
  def sample_mail_preview
    company = Company.find(4)
    member = Member.first
    ReportMailer.sample_email(User.find(6), company, report_data(company.admin, member))
  end

  def report_data(reporter, member)
    report = ReportHelper::Report.new(reporter, '2017-03-27'.to_date, '2017-04-01'.to_date, member: member)
    report.report_member_tasks
  end
end
