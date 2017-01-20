module ProjectApi
    class Projects < Grape::API
        prefix :api
        version 'v1', using: :accept_version_header
        #
        helpers do
            def something
            end
        end

        resource :projects do
            # => /api/v1/projects/
            desc 'Get all projects'
            post '/all' do
                Project.all
            end

            desc 'Get a project by id'
            params do
                requires :id, type: String, desc: 'Project ID'
            end
            get ':id' do
              Project.where(id: params[:id]).first!
            end

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

                member_roles_params = project_params['member_roles']
                if member_roles_params && !member_roles_params.nil? && member_roles_params.length > 0
                  member_roles_params.each do |member_roles|
                    project.project_user_roles.create!(
                      project_id: project.id,
                      user_id: member_roles.user_id,
                      role_id: member_roles.role_id
                    )
                  end
                  project
                else
                    {"error":"try again!"}
                end
            end
        end
    end
end
