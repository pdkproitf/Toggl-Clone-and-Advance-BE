class InviteMailer < ApplicationMailer
    def send_invite(invite, invite_token, link)
        @invite = invite
        @link = link
        @invite_token = invite_token
        mail(to: @invite.email, subject: "Welcome to #{@invite.sender.company.name}".upcase)
    end
end
