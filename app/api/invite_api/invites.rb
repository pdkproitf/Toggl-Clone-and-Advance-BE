module InviteApi
    class Invites < Grape::API
        prefix :api
        version 'v1', using: :accept_version_header

        helpers do
            def create_invite(recepter)
                invite = recepter.blank? ? @current_member.sent_invites.create!(email: params['email']) :
                    @current_member.sent_invites.create!(email: params['email'], recipient_id: recepter.id)
            end

            def invite_inform(invite, recepter)
                link = recepter.blank? ? 'sign-up/' : 'invites-confirm/'

                link += invite.invite_token + '/' + @current_member.company.name +
                    '/' + @current_member.company.domain
                invite.send_email "#{Settings.front_end}/#/#{link}"
            end

            def create_default_job
                @member.jobs_members.create!(job_id: Job.find_or_create_by(name: 'Developper'))
            end
        end

        resource :invites do
            desc 'Confirmation invites with member exist account'
            params do
                requires :email, type: String, desc: 'Email New Member'
                requires :token, type: String, desc: 'Token Confirm Invite Member'
            end
            put do
                @invite = Invite.find_by_email(params['email'])
                error!(I18n.t("not_found", title: "invite"), 404)  unless @invite
                error!(I18n.t("invite.errors.token_error")) unless @invite.authenticated?(params['token'])
                error!(I18n.t("expiry", title: "Invitation")) if @invite.expiry?

                user = User.find_by_email(@invite.email)
                error!(I18n.t("user.must_exit")) unless user

                Invite.transaction do
                    @invite.update_attributes!(recipient_id: user.id, is_accepted: true, invite_token: nil)
                    member_role = Role.find_or_create_by!(name: 'Member')
                    Member.transaction do
                        @invite.sender.company.members.create!(user_id: @invite.recipient_id,
                            role_id: member_role.id)
                        create_default_job
                        return return_message I18n.t("success")
                    end
                end
            end

            before do
                authenticated!
            end

            desc 'Get all Invite'
            get do
                error!(I18n.t("access_denied")) unless @current_member.admin? || @current_member.pm?
                return_message(I18n.t('success'), Invite.all.map { |e|  InviteSerializer.new(e)})
            end

            desc 'Invite member to company'
            params do
                requires :email, type: String, desc: 'Email New Member'
            end
            post '/' do
                error!(I18n.t("access_denied")) unless @current_member.admin? || @current_member.pm?
                invite = Invite.find_by_email(params['email'])

                recepter = User.find_by_email(params['email'])
                error!("user.errors.already_member", 400) if recepter &&
                    recepter.members.find_by_company_id(@current_member.company_id)

                # crete invite and send email to peron invited
                messages = if invite.blank?
                    invite = create_invite(recepter)
                    I18n.t("invite.success", email: params['email'])
                else
                    invite.generate_token
                    invite.generate_expry
                    invite.save!
                    I18n.t("invite.errors.sended", email: params['email'])
                end

                invite_inform(invite, recepter)

                return_message(messages)
            end

            desc 'Delete Invites'
            delete ':id' do
                invite = Invite.find(params[:id])
                error!(I18n.t('not_found', title: "Invitetion"), 404) unless invite
                if (invite.sender_id == @current_member.id) || @current_member.admin?
                    error!(I18n.t('access_denied'))
                end

                invite.destroy!
                return_message(I18n.t('success'))
            end
        end
    end
end
