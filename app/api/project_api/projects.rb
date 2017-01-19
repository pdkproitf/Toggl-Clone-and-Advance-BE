module ProjectApi
    class Projects < Grape::API
        prefix :api
        version 'v1', using: :accept_version_header
        #
        helpers do
            def sign_up_params
                user_params = params['user']
                user = User.new(
                    name: user_params['name'],
                    email: user_params['email'],
                    password: user_params['password'],
                    password_confirmation: user_params['password_confirmation']
                )
                user
            end

            def render_create_success
                {
                    status: 'success',
                    data:   @resource
                }
            end

            def render_create_error
                {
                    status: 'error',
                    data:    @resource,
                    errors: '',
                    code: 422
                }
            end
        end

        resource :projects do
            # => /api/v1/projects/
            desc 'create new project'
            params do
                requires :project, type: Hash do
                    requires :name, type: String, desc: 'Project name.'
                    requires :client_id, type: Integer, desc: 'Client id'
                    requires :background, type: String, desc: 'Background color'
                    requires :report_permission, type: Integer, desc: 'Report permission'
                    optional :member_roles, type: Array, desc: 'Member roles' do
                        requires :user_id, type: Integer, desc: 'User id'
                        requires :role_id, type: Integer, desc: 'Role id'
                    end
                    optional :category_members, type: Hash do
                        requires :existing, type: Array, desc: 'Existing categories' do
                            requires :category_id, type: Integer, desc: 'Category id'
                            requires :members, type: Array, desc: 'Member' do
                                requires :user_id, type: Integer, desc: 'User id'
                            end
                            requires :billable, type: Boolean, desc: 'Billable'
                        end
                        optional :new, type: Array, desc: 'New categories' do
                            requires :category_name, type: String, desc: 'New category name'
                            requires :members, type: Array, desc: 'Member' do
                                requires :user_id, type: Integer, desc: 'User id'
                            end
                            requires :billable, type: Boolean, desc: 'Billable'
                        end
                    end
                end
            end
            post '/new' do
                project_params = params['project']
                project = Project.create!(
                    name: project_params['name'],
                    client_id: project_params['client_id'],
                    background: project_params['background'],
                    report_permission: project_params['report_permission']
                )
            end

            # for test
            params do
                requires :test, type: Array do
                    requires :int, type: Integer
                    requires :ints, type: Integer
                end
            end
            post '/test' do
                params[:test]
            end
        end
    end
end
