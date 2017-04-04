module RoleApi
    class Roles < Grape::API
        prefix :api
        version 'v1', using: :accept_version_header

        helpers MemberHelper

        resource :roles do
            before do
                authenticated!
                error!(I18n.t("access_denied"), 403) unless @current_member.admin?
            end

            desc 'get all roles in company'
            get '/' do
                return_message(I18n.t("success"),
                    Role.all.map {|e| RolesSerializer.new(e)})
            end
        end
    end
end
