class ReportMailer < ApplicationMailer
  def sample_email(user, data, start_date, end_date)
    @user = user
    @data = data
    @start_date = start_date
    @end_date = end_date
    mail to: @user.email, subject: 'Time Cloud weekly report'
  end
end

# class ReportMailer < ApplicationMailer
#   def sample_email(user, company, data, start_date, end_date)
#     @user = user
#     @company = company
#     @data = data
#     @start_date = start_date
#     @end_date = end_date
#     mail to: @user.email, subject: 'Time Cloud weekly report'
#   end
# end
