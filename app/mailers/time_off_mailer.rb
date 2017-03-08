class TimeOffMailer < ApplicationMailer
    def timeoff_announce(timeoff, email, current_member = nil)
        @timeoff = timeoff
        @mail = email
        @current_member = current_member
        mail(to: email, subject: "Member Day Off at #{timeoff.sender.company.name} Company".upcase)
    end
end
