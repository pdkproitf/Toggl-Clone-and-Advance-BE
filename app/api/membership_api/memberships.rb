module MembershipApi
    class Memberships < Grape::API
        prefix :api
        version 'v1', using: :accept_version_header
        
        helpers do
        end

        resource :memberships do
            desc 'Get all members in team'
            get '/' do
                authenticated!
                member_hash = {}
                member_hash[:employer] = UserSerializer.new(@current_user)
                employees = []
                @current_user.employers.each do |employee|
                    employees.push(MembershipSerializer.new(employee))
                end
                member_hash[:employee] = employees
                {"data": member_hash}
            end

            desc 'create new membership'
            params do
                requires :membership, type: Hash do
                    requires :email, type: String, desc: 'Employee ID'
                end
            end
            post '/new' do
                authenticated!
                membership_params = params['membership']
                begin
                    employee = User.find_by(email: membership_params['email'])
                    if employee.email.eql? @current_user.email
                        return error!(I18n.t('already_member'), 400)
                    end
                rescue => e
                    return e
                end

                begin
                    membership = Membership.create!(
                        employer_id: @current_user.id,
                        employee_id: employee.id
                    )
                    {"message": "Invitation was sent to "}
                rescue => e
                    return error!(I18n.t('already_member'), 400)
                end

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
