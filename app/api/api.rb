require 'grape-swagger'
module API
  class Root < Grape::API
    format :json
    # formatter :json #, Grape::Formatter::ActiveModelSerializers
    use ApiErrorHandler

    mount UserApi::Data
    # mount Shop::ProductApi

    add_swagger_documentation(
      api_version: 'v1',
      hide_doccumentation_path: false,
       mount_path: "/api/v1/swagger_doc",
      hide_format: true,
      info: {
        title: "TRACKING TIME API"
      }
    )
  end
end
