class ReportMailer < ApplicationMailer
  def sample_email(user, company, data)
    @user = user
    @company = company
    @data = data
    mail to: @user.email, subject: 'Time Cloud weekly report'
  end
end
