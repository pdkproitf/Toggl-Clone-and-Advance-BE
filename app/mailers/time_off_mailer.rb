class TimeOffMailer < ApplicationMailer
    def timeoff_announce(timeoff, email)
        @timeoff = timeoff
        @mail = email
        mail(to: email, subject: "Member Day Off at #{timeoff.sender.company.name} Company".upcase)
    end
end
