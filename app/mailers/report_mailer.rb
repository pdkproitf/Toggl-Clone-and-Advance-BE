class ReportMailer < ApplicationMailer
  def sample_email(user, company)
    @user = user
    @company = company
    mail to: @user.email, subject: 'Time Cloud weekly report'
  end
end
