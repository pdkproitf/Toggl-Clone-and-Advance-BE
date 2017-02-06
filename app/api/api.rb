require 'grape-swagger'
module API
  class Root < Grape::API
    format :json
    # formatter :json #, Grape::Formatter::ActiveModelSerializers
    use ApiErrorHandler

    helpers do
      def authenticated!
        email = request.headers['uid']
        client_id = request.headers['client']
        token = request.headers['access_token']

        @current_user = User.find_by_email(email)

        unless @current_user.nil?
          return @current_user if @current_user.valid_token?(token, client_id)
        end
        
        @current_user = nil
      end
    end

    mount UserApi::Registrations
    mount UserApi::Confirmations
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
