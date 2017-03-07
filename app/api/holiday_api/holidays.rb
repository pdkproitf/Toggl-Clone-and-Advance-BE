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
      get '/' do
        Holiday.all
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
        authentication!
        @current_member
      end
    end
  end
end
