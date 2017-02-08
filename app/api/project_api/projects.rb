module ProjectApi
    class Projects < Grape::API
        prefix :api
        version 'v1', using: :accept_version_header
        #
        helpers do
            def project_category_user_create(project_category_id, user_id)
                ProjectCategoryUser.create!(
                    project_category_id: project_category_id,
                    user_id: user_id
                )
            end

            def project_category_create(project_id, category_id, billable)
                ProjectCategory.create!(
                    project_id: project_id,
                    category_id: category_id,
                    billable: billable
                )
            end
        end

        resource :projects do
            # => /api/v1/projects/
            desc 'Get all projects'
            get '/test' do
                Project.find(10).get_tracked_time
            end

            desc 'Get all projects'
            get '/all' do
                authenticated!
                project_list = @current_user.projects

                list = []
                project_list.each do |project|
                  member_list = []
                  project.project_user_roles.each do |member|
                      member_list.push(member.user)
                  end

                  item = {
                    "info": ProjectSerializer.new(project),
                    "tracked_time": project.get_tracked_time,
                    "member": member_list
                  }
                  list.push(item)
                end
                {data: list}
            end

            desc 'Get a project by id'
            params do
                requires :id, type: String, desc: 'Project ID'
            end
            get ':id' do
                authenticated!
                project = @current_user.projects.where(id: params[:id]).first!
                list = []
                user_list = {}
                cate_list = {}
                project.project_categories.each do |pc|
                    old_pcu_user_id = -1
                    old_pcu_project_category_id = -1
                    pc.project_category_users.each do |pcu|
                      # For user
                      if pcu.user_id != old_pcu_user_id
                        user_list[pcu.user_id] = UserSerializer.new(pcu.user)
                        old_pcu_user_id = pcu.user_id
                      end

                      # For Category
                      if pcu.project_category_id != old_pcu_project_category_id
                        cate_list[pcu.project_category_id] = CategorySerializer.new(pcu.project_category.category)
                        old_pcu_project_category_id = pcu.project_category_id
                      end

                      # For data
                      item = Hash.new
                      item.merge!(ProjectCategoryUserSerializer.new(pcu).attributes)
                      item[:tracked_time] = pcu.get_tracked_time
                      list.push(item)
                    end
                end

                result = { data: list,
                  member_total: project.project_user_roles.length,
                  project_category: cate_list,
                  user: user_list
                }
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
                        optional :new_one, type: Array, desc: 'New categories' do
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
                authenticated!

                project_params = params['project']
                flag = true
                if project_params['category_members']['new_one']
                  newList = project_params['category_members']['new_one']
                  newList.each do |cate|
                    if Category.exists?(:name => cate["category_name"])
                      flag = false
                      break
                    end
                  end
                end

                if flag
                  project = @current_user.projects.create!(
                      name: project_params['name'],
                      client_id: project_params['client_id'],
                      background: project_params['background'],
                      report_permission: project_params['report_permission']
                  )

                  # Add member role (option)
                  if project_params['member_roles']
                      member_roles_params = project_params['member_roles']
                      member_roles_params.each do |member_roles|
                          project.project_user_roles.create!(
                              project_id: project.id,
                              user_id: member_roles.user_id,
                              role_id: member_roles.role_id
                          )
                      end
                  end

                  # Add project category (option)
                  if project_params['category_members']
                      # For existing categories
                      if project_params['category_members']['existing']
                          existingList = project_params['category_members']['existing']
                          existingList.each do |existing|
                              project_category = project_category_create(
                                  project.id,
                                  existing.category_id,
                                  existing.billable
                              )
                              existing['members'].each do |member|
                                  project_category_user_create(project_category.id, member.user_id)
                              end
                          end
                      end

                      # For new categories
                        newList = project_params['category_members']['new_one']
                        newList.each do |new_cate|
                              category = Category.create!(name: new_cate['category_name'])
                              project_category = project_category_create(
                                  project.id,
                                  category.id,
                                  new_cate.billable
                              )
                              new_cate['members'].each do |member|
                                project_category_user_create(project_category.id, member.user_id)
                              end
                          end
                      end
                      project
                    else
                      {"error": "Category name is taken"}
                end # End of flag
            end # End of project add new

            desc 'Delete a project'
            params do
                requires :id, type: String, desc: 'Project ID'
            end
            delete ':id' do
                authenticated!
                project = @current_user.projects.where(id: params[:id]).first!
                project.destroy
            end


        end
    end
end
