class SendReportJob < ApplicationJob
  queue_as :default

  def perform(*_args)
    puts 'Send report Oh yeah!'
  end
end
