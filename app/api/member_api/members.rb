module MemberApi
    class Members < Grape::API
        prefix :api
        version 'v1', using: :accept_version_header

        resource :members do
            desc 'get all member'
            get '/' do
                authenticated!
                error!(I18n.t("access_denied"), 403) unless @current_member.admin? || @current_member.pm?
                return_message I18n.t("success"), @current_member.company.members.map {|e| MembersSerializer.new(e)}
            end
        end
    end
end
