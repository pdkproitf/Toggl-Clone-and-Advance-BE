# app/workers/weekly_worker.rb
class WeeklyWorker
  include Sidekiq::Worker

  MAIL_MONTH = 1

  def perform(action)
    case action
    when MAIL_MONTH
      # Course.all.each do |course|
      #   send_email_when_end_month course
      # end
      send_email_when_end_month(User.find(6))
    end
  end

  private

  def send_email_when_end_month(user)
    ReportMailer.sample_email(user).deliver_now
  end
end
