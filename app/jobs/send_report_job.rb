class SendReportJob < ApplicationJob
  queue_as :default

  def perform(args)
    puts 'Send report Oh yeah!'
    company = Company.find(args['company_id'])
    active_users = company.active_users

    active_users.each do |user|
      puts user.email
      ReportMailer.sample_email(user, company).deliver_now
    end
  end
end
