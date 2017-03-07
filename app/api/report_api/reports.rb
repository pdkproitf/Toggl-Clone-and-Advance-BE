module ReportApi
  class Reports < Grape::API
    prefix :api
    version 'v1', using: :accept_version_header
    #
    helpers do
    end

    resource :reports do
      # => /api/v1/reports/
      desc 'Get company of admin'
      get do
        authenticated!
        return error!(I18n.t('access_denied'), 400) unless @current_member.admin?
        @current_member.company
      end
    end
  end
end
