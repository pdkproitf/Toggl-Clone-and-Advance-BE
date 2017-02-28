module MemberApi
    class Members < Grape::API
        prefix :api
        version 'v1', using: :accept_version_header

        helpers do
            def invite_new_user invite
                invite ? invite.generate_token : (invite = @current_member.sent_invites.create!(email: params['email']))
                invite.save!
                InviteMailer.send_invite(invite, invite.invite_token, 'https://spring-time-tracker.herokuapp.com/#/sign-up/'+invite.invite_token).deliver_later
            end

            def invite_exist_user invite, recepter
                invite ? invite.generate_token : (invite = @current_member.sent_invites.build(email: params['email'], recipient_id: recepter.id))
                invite.save!
                InviteMailer.send_invite(invite, invite.invite_token, 'https://spring-time-tracker.herokuapp.com/#/members_confirm/'+invite.invite_token).deliver_later
            end
        end

        resource :members do
            desc 'get all member'
            get '/' do
                authenticated!
                return return_message 'Access Denied, Just Admin and PM able to do this.' unless @current_member.admin? || @current_member.pm?
                return_message 'Success', @current_member.company.members.map { |e|  MembersSerializer.new(e)}
            end

            desc 'Invite member to company'
            params do
                requires :email, type: String, desc: 'Email New Member'
            end
            post '/' do
                authenticated!
                return return_message 'Access Denied, Just Admin and PM able to do this.' unless @current_member.admin? || @current_member.pm?

                invite = Invite.find_by_email(params['email'])
                messages =  invite ? "You already sent the mail invete to #{params['email']}. New invite will be send after few minutes" : 'Success, The email confirm will be send after few minutes'
                recepter = User.find_by_email(params['email'])
                return error!('User already member', 400) if recepter && recepter.members.find_by_company_id(@current_member.company_id)

                recepter.nil? ? (invite_new_user invite) : (invite_exist_user invite, recepter)
                return_message messages
            end

            desc 'Confirmation invites with member exist account'
            params do
                requires :email, type: String, desc: 'Email New Member'
                requires :token, type: String, desc: 'Token Confirm Invite Member'
            end
            put do
                @invite = Invite.find_by_email(params['email'])
                return return_message 'Not Found' unless @invite
                return return_message 'Error Token un authenticated' unless @invite.authenticated?(params['token'])
                return return_message 'Link confirm expiry' if @invite.expiry?

                @invite.is_accepted = true
                Invite.transaction do
                    @invite.save!
                    member = Role.find_by_name('Member') || Role.create!(name: 'Member')
                    Member.transaction do
                        @invite.sender.company.members.create!(user_id: @invite.recipient_id, role_id: member.id)
                        return return_message 'Success, You can login under '+@invite.sender.company.name+'s company'
                    end
                end
            end
        end
    end
end
