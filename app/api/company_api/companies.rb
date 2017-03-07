module CompanyApi
  class Companies < Grape::API
    prefix :api
    version 'v1', using: :accept_version_header
    #
    helpers do
    end

    resource :companies do
      # => /api/v1/companies/
      desc 'Get all companies'
      get '/' do
        Company.all
      end

      desc 'Get a category by id'
      get ':id' do
      end

      desc 'create new category'
      params do
        requires :category, type: Hash do
          requires :name, type: String, desc: 'Category name'
          requires :default, type: Boolean, desc: 'Default'
        end
      end
      post '/' do
      end

      desc 'Delete a category'
      delete ':id' do
      end
    end
  end
end
