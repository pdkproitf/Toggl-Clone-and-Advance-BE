require 'grape-swagger'
module API
  class Root < Grape::API
    format :json
    # formatter :json #, Grape::Formatter::ActiveModelSerializers
    use ApiErrorHandler

    helpers do
      def authenticated!
        error!("401 Unauthorized", 401) unless current_user
      end

      def current_user
        email = request.headers['Uid']
        client_id = request.headers['Client']
        token = request.headers['Access-Token']

        @current_user = User.find_by_email(email)

        unless @current_user.nil?
          return @current_user if @current_user.valid_token?(token, client_id)
        end

        @current_user = nil
      end
    end

    mount UserApi::Registrations
    mount UserApi::Sessions
    mount UserApi::Passwords

    mount ProjectApi::Projects
    mount ClientApi::Clients

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
