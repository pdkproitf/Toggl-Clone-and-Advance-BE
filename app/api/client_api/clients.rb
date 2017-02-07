module ClientApi
    class Clients < Grape::API
        prefix :api
        version 'v1', using: :accept_version_header
        #
        helpers do
        end

        resource :clients do
            # => /api/v1/projects/
            desc 'Get all clients'
            get '/all' do
                authenticated!
                @current_user.clients
            end

            desc 'Get a client by id'
            params do
                requires :id, type: String, desc: 'Client ID'
            end
            get ':id' do
                authenticated!
                @current_user.clients.where(id: params[:id]).first!
            end

            desc 'create new client'
            params do
                requires :client, type: Hash do
                    requires :name, type: String, desc: 'Client name'
                end
            end
            post '/new' do
                authenticated!

                client_params = params['client']
                client = @current_user.clients.create!(
                    name: client_params['name']
                )
                client
            end

            desc 'Delete a client'
            params do
                requires :id, type: String, desc: 'Client ID'
            end
            delete ':id' do
                authenticated!
                client = @current_user.clients.where(id: params[:id]).first!
                client.destroy
            end
        end
    end
end
