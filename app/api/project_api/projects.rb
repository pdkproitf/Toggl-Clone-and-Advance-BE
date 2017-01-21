module ProjectApi
    class Projects < Grape::API
        prefix :api
        version 'v1', using: :accept_version_header
        #
        helpers do
            def project_category_user_create(project_category_id, user_id)
                ProjectCategoryUser.create!(project_category_id: project_category_id, user_id: user_id)
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

                # Add member role
                if project_params['member_roles']
                  member_roles_params = project_params['member_roles']
                end
                if member_roles_params
                    member_roles_params.each do |member_roles|
                        project.project_user_roles.create!(
                            project_id: project.id,
                            user_id: member_roles.user_id,
                            role_id: member_roles.role_id
                        )
                    end
                end

                # Add project category
                # For existing categories
                if project_params['category_members'] &&
                   project_params['category_members']['existing']
                  existingList = project_params['category_members']['existing']
                end
                if existingList
                    existingList.each do |existing|
                        project_category = project.project_categories.create!(
                            project_id: project.id,
                            category_id: existing.category_id,
                            billable: existing.billable
                        )
                        existing['members'].each do |member|
                            project_category_user_create(project_category.id, member.user_id)
                        end
                    end
                end

                # For new categories
                if project_params['category_members']&&
                   project_params['category_members']['new']
                   newList = project_params['category_members']['new']
                end
                if newList
                    newList.each do |new_cate|
                        category = Category.create!(name: new_cate['category_name'])
                        project_category = project.project_categories.create!(
                            project_id: project.id,
                            category_id: category.id,
                            billable: new_cate.billable
                        )
                        new_cate['members'].each do |member|
                            project_category_user_create(project_category.id, member.user_id)
                        end
                    end
                end

                project
                 #{"data": "tuc"}
            end # End of project add new

            desc 'Delete a project'
            params do
                requires :id, type: String, desc: 'Project ID'
            end
            delete ':id' do
              project = Project.find(params[:id])
              project.destroy
            end
        end
    end
end
