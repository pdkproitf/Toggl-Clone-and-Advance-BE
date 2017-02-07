module MembershipApi
    class Memberships < Grape::API
        prefix :api
        version 'v1', using: :accept_version_header
        #
        helpers do
        end

        resource :memberships do
            # => /api/v1/projects/
            desc 'Get all memberships'
            get '/all' do
                Membership.all
            end

            desc 'create new membership'
            params do
                requires :membership, type: Hash do
                    requires :employer_id, type: Integer, desc: 'Employer ID'
                    requires :employee_id, type: Integer, desc: 'Employee ID'
                end
            end
            post '/new' do
                membership_params = params['membership']
                membership = Membership.create!(
                    employer_id: membership_params['employer_id'],
                    employee_id: membership_params['employee_id']
                )
                membership
            end
        end
    end
end
