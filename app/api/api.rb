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
    mount TimerApi::Timers
    mount MemberApi::Members
    mount InviteApi::Invites
    mount TaskApi::Tasks
    mount TimeOffApi::TimeOffs
    mount CompanyApi::Companies
    mount HolidayApi::Holidays
    mount ReportApi::Reports
    mount ReportApi::ReportAdvances
    mount JobApi::Jobs

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
