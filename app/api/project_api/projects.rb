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
            desc 'Get all projects that I own'
            get '/' do
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

            desc 'Get all projects that I join'
            get '/join' do
                authenticated!
                pcu_list = @current_user.project_category_users
                  .where.not(project_category_id: nil)
                  .joins(project_category: [{project: :client} , :category])
                  .select("project_category_users.id as pcu_id")
                  .select("project_categories.id")
                  .select("projects.name as project_name")
                  .select("clients.id as client_id", "clients.name as client_name")
                  .select("categories.name as category_name")
                  .where(projects: {is_archived: false})
                  .order("projects.id asc") # Change order if you want

                # list = []
                # project_category_id_list = []
                # project_id_list = []
                # pcu_list.each do |pcu|
                #   if !project_category_id_list.include?(pcu.id)
                #     project_category_id_list.push(pcu.id)
                #     item_hash = {}
                #     category = Category.find(pcu.category_id)
                #     if !project_id_list.include?(pcu.project_id)
                #       project_id_list.push(pcu.project_id)
                #       project = Project.find(pcu.project_id)
                #       item_hash.merge!(ProjectSerializer.new(project))
                #       item_hash["category"] = []
                #       cat_ser = CategorySerializer.new(category).as_json
                #       cat_ser["pcu_id"] = pcu.id
                #       item_hash["category"].push(cat_ser)
                #       list.push(item_hash)
                #     else
                #       result = list.select do |hash|
                #         hash[:id] == pcu.project_id
                #       end
                #       cat_ser = CategorySerializer.new(category).as_json
                #       cat_ser["pcu_id"] = pcu.id
                #       result.first["category"].push(cat_ser)
                #     end
                #   end
                # end
                {"data": pcu_list}
            end

            desc 'Get a project by id'
            params do
                requires :id, type: String, desc: 'Project ID'
            end
            get ':id' do
                authenticated!
                begin
                  project = @current_user.projects.find(params[:id])
                  project_hash = Hash.new
                  project_hash.merge!(ProjectSerializer.new(project).attributes)
                  project_hash[:client_name] = project.client[:name]
                  project_hash[:tracked_time] = project.get_tracked_time

                  pc_list = project.project_categories
                  list = []
                  pc_list.each do |pc|
                    item = Hash.new
                    item.merge!(ProjectCategorySerializer.new(pc))
                    item.delete(:project_id)
                    item.delete(:category_id)
                    item[:category] = CategorySerializer.new(pc.category)
                    item[:tracked_time] = pc.get_tracked_time

                    member_list = []
                    pc.project_category_users.each do |pcu|
                      member_hash = Hash.new
                      member_hash.merge!(ProjectCategoryUserSerializer.new(pcu))
                      member_hash.delete(:id)
                      member_hash.delete(:user_id)
                      role = ProjectUserRole.joins(:role).where(project_id: project.id, user_id: pcu.user.id).select("roles.id", "roles.name")
                      member_hash[:user] = UserSerializer.new(pcu.user)
                      member_hash[:role] = role
                      member_hash[:tracked_time] = pcu.get_tracked_time
                      member_list.push(member_hash)
                    end
                    item[:member] = member_list

                    list.push(item)
                  end
                  {"data":{
                    "info": project_hash,
                    "project_category": list
                    }
                  }
                rescue => e
                    return error!(I18n.t("project_not_found"), 404)
                end
            end

            desc 'create new project'
            params do
                requires :project, type: Hash do
                    requires :name, type: String, desc: 'Project name.'
                    requires :client_id, type: Integer, desc: 'Client id'
                    requires :background, type: String, desc: 'Background color'
                    requires :report_permission, type: Integer, values: [1, 2], desc: 'Report permission'
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
            post '/' do
                authenticated!

                project_params = params['project']
                flag = true

                is_client_ok = false
                is_users_with_roles_member = nil # Option
                is_roles_exist = nil # Option
                is_categories_exist = nil # Option
                is_users_in_existing_member = nil # Option
                is_category_name_ok = nil # Option
                is_users_in_new_one_member = nil # Option

                # Check if combination project name and client of current user exists
                if @current_user.projects.exists?(:name => project_params["name"], :client_id => project_params["client_id"])
                  return error!(I18n.t("project_name_client_taken"), 400)
                end
                # Check if client belongs to current user
                begin
                    @current_user.clients.find(project_params['client_id'])
                    is_client_ok = true
                rescue => e
                    return error!(I18n.t("client_not_found"), 404)
                end

                # In member_roles, check if all users belong to current user's team
                # and check if not nil roles exist
                if project_params['member_roles']
                  member_roles = project_params['member_roles']
                  member_roles_users = []
                  member_roles.each do |mr|
                    # Check if user belongs to current user's team
                    if mr.user_id != @current_user.id && !Membership.exists?(:employer => @current_user.id, :employee => mr.user_id)
                      return error!(I18n.t("user_not_member"), 400)
                    end
                    # Check if not nil role exists
                    if !mr.role_id.nil? && !Role.exists?(:id => mr.role_id)
                      return error!(I18n.t("role_not_found"), 400)
                    end

                    member_roles_users.push(mr.user_id)
                  end
                  is_users_with_roles_member = true
                  is_roles_exist = true
                end

                # Check category_members (member_roles must exist in advance)
                if project_params['category_members']
                  if member_roles_users
                    category_members = project_params['category_members']
                    # In existing
                    if category_members['existing']
                      existing = category_members['existing']
                      existing.each do |exist|
                        # Check if categories exist
                        if !Category.exists?(:id => exist.category_id)
                          return error!(I18n.t("category_not_found"), 400)
                        end
                        # Check if users was added to project
                        exist.members.each do |member|
                          if !member_roles_users.include?(member.user_id)
                            return error!(I18n.t("user_not_added_to_project"), 400)
                          end
                        end
                      end
                      is_categories_exist = true
                      is_users_in_existing_member = true
                    end # End existing

                    # In new_one
                    if category_members['new_one']
                      new_ones = category_members['new_one']
                      new_ones.each do |new_one|
                        # Check if categories names were taken
                        if Category.exists?(:name => new_one.category_name)
                          return error!(I18n.t("category_name_taken"), 400)
                        end
                        # Check if users was added to project
                        new_one.members.each do |member|
                          if !member_roles_users.include?(member.user_id)
                            return error!(I18n.t("user_not_added_to_project"), 400)
                          end
                        end
                      end
                      is_category_name_ok = true
                      is_users_in_new_one_member = true
                    end
                  else # member_roles not exist
                    return error!(I18n.t("user_not_added_to_project"), 400)
                  end
                end

                # Start to create
                # Create basic project
                if is_client_ok
                  project = @current_user.projects.create!(
                      name: project_params['name'],
                      client_id: project_params['client_id'],
                      background: project_params['background'],
                      report_permission: project_params['report_permission']
                  )
                end

                # Add member role (option)
                if is_users_with_roles_member == true && is_roles_exist == true
                    member_roles_params = project_params['member_roles']
                    member_roles_params.each do |member_roles|
                        project.project_user_roles.create!(
                            project_id: project.id,
                            user_id: member_roles.user_id,
                            role_id: member_roles.role_id
                        )
                    end
                end

                # Add existing categories member
                if is_categories_exist == true && is_users_in_existing_member == true
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

                # Add new categories and members
                if is_category_name_ok = true && is_users_in_new_one_member == true
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

                {"message": "Create project successfully"}
            end # End of project add new

            desc 'Delete a project'
            params do
                requires :id, type: String, desc: 'Project ID'
            end
            delete ':id' do
                authenticated!
                status 200
                begin
                  project = @current_user.projects.find(params[:id])
                  project.destroy
                  {"message" => "Delete project successfully"}
                rescue => e
                  error!(I18n.t("project_not_found"), 400)
                end
            end
        end
    end
end
