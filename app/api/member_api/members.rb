module MemberApi
    class Members < Grape::API
        prefix :api
        version 'v1', using: :accept_version_header

        helpers MemberHelper

        resource :members do
            before do
                authenticated!
            end

            desc 'get all member in company'
            get '/' do
                error!(I18n.t("access_denied"), 403) unless @current_member.manager?
                return_message I18n.t("success"),
                    @current_member.company.members.map {|e| MembersSerializer.new(e)}
            end

            desc 'get a member inform in company'
            get ':id' do
                member = Member.find(params[:id])
                error!(I18n.t("access_denied"), 403) unless able_see_member?(member)
                return_message(I18n.t('success'), MembersSerializer.new(member))
            end

            desc 'edit member in company inform: role, jobs, role'
            params do
                requires :members, type: Hash do
                    requires :role_id, type: Integer, desc: 'member role'
                    requires :jobs, type: Array[Integer], desc: 'array job id'
                end
            end
            put ':id' do
                member = Member.find(params[:id])
                error!(I18n.t("access_denied"), 403) unless able_modify_member?(member)

                Member.transaction do
                    update_role(params[:members][:role_id], member)
                    update_jobs(params[:members][:jobs], member)
                end

                return_message(I18n.t('success'), MembersSerializer.new(member.reload))
            end

            after do
                archived_project_member(@member)
            end

            desc 'reject member from company'
            delete ':id' do
                @member = Member.find(params[:id])
                error!(I18n.t("access_denied"), 403) unless able_modify_member?(@member)
                error!(I18n.t("member.errors.already_archived"), 400) unless @member.actived?
                @member.update_attributes(is_archived: true)
                status 200
                return_message(I18n.t('success'))
            end
        end
    end
end
