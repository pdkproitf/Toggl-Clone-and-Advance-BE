class InviteMailer < ApplicationMailer

    def send_invite(invite, link)
        @invite = invite
        @link = link
        mail(to: @invite.email, subject: "Welcome to #{@invite.company.name}".upcase)
    end
end
