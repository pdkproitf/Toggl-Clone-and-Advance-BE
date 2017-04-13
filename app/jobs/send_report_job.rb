class SendReportJob < ApplicationJob
  queue_as :default

  def perform(args)
    puts 'Send report Oh yeah!'
    company = Company.find(args['company_id'])
    puts company.name
    # ReportMailer.sample_email(User.find(6)).deliver_now
  end
end
