module CompanyApi
  class Companies < Grape::API
    prefix :api
    version 'v1', using: :accept_version_header
    #
    helpers do
    end

    resource :companies do
      # => /api/v1/companies/
      desc '[For development] Get all companies'
      get '/' do
        Company.all
      end

      desc 'Get a company by id'
      get ':id' do
      end

      desc 'Edit a company'
      params do
        requires :company, type: Hash do
          requires :name, type: String, desc: 'Company name'
          optional :overtime_max, type: Integer, desc: 'Overtime maximum'
          optional :begin_week, type: Integer, values: 0..6,
                                desc: 'Begin day of week'
        end
      end
      put :id do
        @current_member = Member.find(1)
      end

      desc 'Delete a company'
      delete ':id' do
      end
    end
  end
end
