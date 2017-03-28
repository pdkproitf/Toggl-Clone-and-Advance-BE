module MemberApi
    class Members < Grape::API
        prefix :api
        version 'v1', using: :accept_version_header

        helpers MemberHelper

        resource :members do
            before do
                authenticated!
            end

            desc 'get all member'
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
        end
    end
end
