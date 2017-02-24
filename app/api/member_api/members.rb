module MemberApi
    class Members < Grape::API
        prefix :api
        version 'v1', using: :accept_version_header

        helpers do
            def invite_new_user
                invive = @current_member.user.sent_invites.create!(
                    email: params['email'],
                    company_id: @current_member.company_id)
                InviteMailer.send_invite(invive, 'https://spring-time-tracker.herokuapp.com/#/sign_up').deliver_later(wait: 2.minutes)
            end

            def invite_exist_user recepter
                invive = @current_member.user.sent_invites.create!(
                email: params['email'],
                company_id: @current_member.company_id,
                recipient_id: recepter.id
                )
                InviteMailer.send_invite(invive, 'https://spring-time-tracker.herokuapp.com/#/sign_up').deliver_later(wait: 2.minutes)
            end
        end

        resource :members do
            desc 'get all member'
            get '/' do
                authenticated!
                return return_message 'Access Denied, Just Admin and PM able to do this.' unless @current_member.admin? || @current_member.pm?
                return_message 'Success', MembersSerializer.new(@current_member.company.members)
            end

            desc 'Invite member to company'
            params do
                requires :email, type: String, desc: 'Email New Member'
            end
            post '/' do
                authenticated!
                return return_message 'Access Denied, Just Admin and PM able to do this.' unless @current_member.admin? || @current_member.pm?
                recepter = User.find_by_email(params['email'])
                recepter.nil? ? (invite_new_user) : (invite_exist_user recepter)
                return_message 'Success, The email confirm will be send after few minutes'
            end

            desc 'Confirmation invites with member exist account'
            params do
                requires :token, type: String, desc: 'Token Confirm Invite Member'
            end
            put do
                @invite = Invite.find_by_token(params['token'])
                return return_message 'Not Found' unless @invite
                return return_message 'Link confirm expiry' if @invite.expiry?
                @invite.is_accepted = true
                Invite.transaction do
                    @invite.save!
                    member = Role.find_by_name('Member')
                    Member.transaction do
                        @invite.company.members.create!(user_id: @invite.recipient_id, role_id: member.id)
                    end
                end
            end
        end
    end
end
