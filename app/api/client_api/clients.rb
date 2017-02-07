module ClientApi
    class Clients < Grape::API
        prefix :api
        version 'v1', using: :accept_version_header
        #
        helpers do
        end

        resource :clients do
            # => /api/v1/projects/
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
        end
    end
end
