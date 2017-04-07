class ReportMailer < ApplicationMailer
  def sample_email(user)
    @user = user
    mail to: @user.email, subject: 'Tracked Time Report'
  end
end
