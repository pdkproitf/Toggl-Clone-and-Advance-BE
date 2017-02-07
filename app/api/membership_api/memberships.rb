module MembershipApi
    class Memberships < Grape::API
        prefix :api
        version 'v1', using: :accept_version_header
        #
        helpers do
        end

        resource :memberships do
            desc 'Get all employees'
            get '/all' do
                authenticated!
                @current_user.employers
            end

            desc 'create new membership'
            params do
                requires :membership, type: Hash do
                    requires :employee_id, type: Integer, desc: 'Employee ID'
                end
            end
            post '/new' do
                authenticated!
                membership_params = params['membership']
                membership = Membership.create!(
                    employer_id: @current_user.id,
                    employee_id: membership_params['employee_id']
                )
                membership
            end

            desc 'Delete a employee'
            params do
                requires :id, type: String, desc: 'Employee ID'
            end
            delete ':id' do
                authenticated!
                employee = @current_user.employers.where(employee_id: params[:id]).first!
                employee.destroy
            end
        end
    end
end
