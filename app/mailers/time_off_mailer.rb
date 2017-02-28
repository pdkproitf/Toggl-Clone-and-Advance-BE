class TimeOffMailer < ApplicationMailer
    def timeoff_announce(timeoff, member, email)
        @timeoff = timeoff
        @member = member
        @mail = email
        mail(to: email, subject: "Member Day Off at #{member.company.name} Company".upcase)
    end
end
