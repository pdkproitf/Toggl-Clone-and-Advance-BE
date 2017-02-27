module ClientApi
    class Clients < Grape::API
        prefix :api
        version 'v1', using: :accept_version_header
        #
        helpers do
            def is_admin_or_pm
                authenticated!
                # Current user has to be an admin or a PM
                if @current_member.role.name == 'Admin' || @current_member.role.name == 'PM'
                    true
                else
                    false
                end
              end
        end

        resource :clients do
            # => /api/v1/projects/
            desc 'Get all clients'
            get do
                return error!(I18n.t('access_denied'), 400) unless is_admin_or_pm
                @current_member.company.clients.order('id asc')
            end

            desc 'Get a client by id'
            params do
                requires :id, type: String, desc: 'Client ID'
            end
            get ':id' do
                return error!(I18n.t('access_denied'), 400) unless is_admin_or_pm
                @current_member.company.clients.where(id: params[:id]).first!
            end

            desc 'create new client'
            params do
                requires :client, type: Hash do
                    requires :name, type: String, desc: 'Client name'
                end
            end
            post do
                return error!(I18n.t('access_denied'), 400) unless is_admin_or_pm
                client = @current_member.company.clients.create!(name: params[:client][:name])
                # create! will raise exception if create new not successfully
                true
            end

            desc 'Delete a client'
            params do
                requires :id, type: String, desc: 'Client ID'
            end
            delete ':id' do
                return error!(I18n.t('access_denied'), 400) unless is_admin_or_pm
                client = @current_member.company.clients.where(id: params[:id]).first!
                client.destroy
            end
        end
    end
end
