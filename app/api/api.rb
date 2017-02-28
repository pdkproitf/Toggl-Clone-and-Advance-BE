require 'grape-swagger'
module API
    class Root < Grape::API
        format :json
        formatter :json, Grape::Formatter::ActiveModelSerializers
        use ApiErrorHandler

        helpers do
            def authenticated!
                error!('401 Unauthorized', 401) unless current_member
            end

            def current_user
                email = request.headers['Uid']
                client_id = request.headers['Client']
                token = request.headers['Access-Token']

                current_user = User.find_by_email(email)
                return current_user unless current_user.nil? || !current_user.valid_token?(token, client_id)
                current_user = nil
            end

            def current_member
                company_domain = request.headers['Company-Domain']
                user = current_user
                return nil unless user

                company = user.companies.find_by_domain(company_domain)
                return nil unless company

                @current_member = user.members.find_by_company_id(company.id)
            end

            def return_message(status, data = nil, code = nil)
                status 400 if status.include?('Error')
                status 404 if status.include?('Not Found')
                status 401 if status.include?('Not Allow') || status.include?('Access Denied')
                {
                    status: status,
                    data: data
                }
            end
        end

        mount UserApi::Registrations
        mount UserApi::Sessions
        mount UserApi::Passwords

        mount ProjectApi::Projects
        mount ClientApi::Clients
        mount CategoryApi::Categories
        mount TimerApi::Timers
        mount MemberApi::Members

        add_swagger_documentation(
            api_version: 'v1',
            hide_doccumentation_path: false,
            mount_path: '/api/v1/swagger_doc',
            hide_format: true,
            info: {
                title: 'TRACKING TIME API'
            }
        )
    end
end
