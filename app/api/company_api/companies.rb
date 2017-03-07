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
      put do
        authenticated!
        return error!(I18n.t('access_denied'), 400) unless @current_member.admin?
        company = @current_member.company
        company[:name] = params[:company][:name]
        unless params[:company][:overtime_max].nil?
          company[:overtime_max] = params[:company][:overtime_max]
        end
        unless params[:company][:begin_week].nil?
          company[:begin_week] = params[:company][:begin_week]
        end
        company.save!
      end

      desc 'Delete a company'
      delete ':id' do
      end
    end
  end
end
