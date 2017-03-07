module HolidayApi
  class Holidays < Grape::API
    prefix :api
    version 'v1', using: :accept_version_header
    #
    helpers do
    end

    resource :holidays do
      # => /api/v1/holidays/
      desc 'Get all holidays'
      get do
        authenticated!
        return error!(I18n.t('access_denied'), 400) unless @current_member.admin?
        @current_member.company.holidays
      end

      desc 'Create new holiday'
      params do
        requires :holiday, type: Hash do
          requires :name, type: String, desc: 'Holiday name'
          requires :begin_day, type: Date, desc: 'Begin day'
          requires :end_day, type: Date, desc: 'End day'
        end
      end
      post do
        authenticated!
        return error!(I18n.t('access_denied'), 400) unless @current_member.admin?
        holiday = @current_member.company.holidays.new
        holiday[:name] = params[:holiday][:name]
        holiday[:begin_day] = params[:holiday][:begin_day]
        holiday[:end_day] = params[:holiday][:end_day]
        holiday.save!
      end
    end
  end
end
