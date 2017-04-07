# app/workers/weekly_worker.rb
class WeeklyWorker
  include Sidekiq::Worker

  def perform
    # Course.all.each do |course|
    #   send_email_when_end_month course
    # end
    send_email(User.find(6))
  end

  private

  def send_email(user)
    ReportMailer.sample_email(user).deliver_now
  end
end
