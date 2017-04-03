class SendReportJob < ApplicationJob
  queue_as :default

  def perform(user)
    @user = user
    ReportMailer.sample_email(@user).deliver_later
  end
end
