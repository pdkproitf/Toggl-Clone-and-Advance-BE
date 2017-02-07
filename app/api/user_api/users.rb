module UserApi
    class Users < Grape::API
        prefix  :api
        version 'v1', using: :accept_version_header

        resource :users do
            # => /api/v1/users/
            desc 'Get all employees'
            get '/employees' do
                authenticated!
                employer_list = @current_user.employers
                employer_list.employee
            end
        end
    end
end
