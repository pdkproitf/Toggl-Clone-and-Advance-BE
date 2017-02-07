module RoleApi
    class Roles < Grape::API
        prefix :api
        version 'v1', using: :accept_version_header
        #
        helpers do
        end

        resource :roles do
            # => /api/v1/roles/
            desc 'Get all roles'
            get '/all' do
                Role.all
            end

            desc 'create new roles'
            params do
                requires :role, type: Hash do
                    requires :name, type: String, desc: 'Role name'
                end
            end
            post '/new' do
                role_params = params['role']
                role = Role.create!(
                    name: role_params['name']
                )
                role
            end
        end
    end
end
