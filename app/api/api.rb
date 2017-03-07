require 'grape-swagger'
module API
  class Root < Grape::API
    format :json
    formatter :json, Grape::Formatter::ActiveModelSerializers
    use ApiErrorHandler

    helpers AuthenticationHelper

    mount UserApi::Registrations
    mount UserApi::Sessions
    mount UserApi::Passwords

    mount ProjectApi::Projects
    mount ClientApi::Clients
    mount CategoryApi::Categories
    mount TimerApi::Timers
    mount MemberApi::Members
    mount TaskApi::Tasks
    mount TimeOffApi::TimeOffs
    mount CompanyApi::Companies
    mount HolidayApi::Holidays

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
