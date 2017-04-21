module CompanyApi
    class Companies < Grape::API
        prefix :api
        version 'v1', using: :accept_version_header
        #
        helpers do
        end

        resource :companies do
            # => /api/v1/companies/
            before do
                authenticated!
            end

            desc 'Get company of admin'
            get 'own' do
                return error!(I18n.t('access_denied'), 403) unless @current_member.admin?
                @current_member.company
            end

            desc 'Edit a company'
            params do
                requires :company, type: Hash do
                    requires :name, type: String, desc: 'Company name'
                    optional :overtime_max, type: Integer, desc: 'Overtime maximum'
                    optional :begin_week, type: Integer, values: 0..6, desc: 'Begin day of week'
                    optional :incre_dayoff, type: Boolean, desc: 'choose mode manage employee dayoff'
                end
            end
            put 'own' do
                return error!(I18n.t('access_denied'), 403) unless @current_member.admin?
                company = @current_member.company
                company[:name] = params[:company][:name]
                company[:overtime_max] = params[:company][:overtime_max] if params[:company][:overtime_max].present?
                company[:begin_week] = params[:company][:begin_week] if params[:company][:begin_week].present?
                company[:incre_dayoff] = params[:company][:incre_dayoff] if params[:company][:incre_dayoff].present?
                company.save!
            end
        end
    end
end
