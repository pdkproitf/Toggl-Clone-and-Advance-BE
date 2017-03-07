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
        requires :category, type: Hash do
          requires :name, type: String, desc: 'Category name'
          requires :default, type: Boolean, desc: 'Default'
        end
      end
      post '/' do
      end
    end
  end
end
