module ProjectApi
    class Projects < Grape::API
        prefix :api
        version 'v1', using: :accept_version_header

        resource :projects do
            # => /api/v1/projects/
            desc 'Get all projects that I own'
            get '/' do
              @current_member = Member.find(1)

              # Current user has to be an admin or a PM
              if @current_member.role == 1 && @current_member.role == 2
                # Get all projects of company
                projects = @current_member.company.projects.where(is_archived: false).order("id desc")
              else
                # Get projects @current_member assigned pm
                projects = @current_member.pm_projects.where(is_archived: false).order("id desc")
              end

              result = []
              projects.each do |project|
                item = {}
                item.merge!(ProjectSerializer.new(project))
                item[:tracked_time] = project.get_tracked_time
                members = []
                project.members.order(:id).each do |member|
                  members.push(UserSerializer.new(member.user))
                end
                item[:member] = members
                result.push(item)
              end

              {"data": result}
            end

            desc 'Get all projects that I join'
            get '/assigned' do
              @current_member = Member.find(1)
              assigned_categories = @current_member.category_members
                .where.not(category_id: nil)
                .where(projects: {is_archived: false})
                .where(categories: {is_archived: false})
                .where(category_members: {is_archived: false})
                .joins(category: {project: :client})
                .select("projects.id", "projects.name", "projects.background")
                .select("clients.id as client_id", "clients.name as client_name")
                .select("categories.name as category_name")
                .select("category_members.id as cm_id")
                .order("projects.id desc", "categories.id asc")

              result = []
              assigned_categories.each do |assigned_category|
                item = result.find { |h| h[:id] == assigned_category[:id] }
                if !item
                  item = {id: assigned_category[:id], name: assigned_category[:name]}
                  item[:background] = assigned_category[:background]
                  item[:client] = {id: assigned_category[:client_id], name: assigned_category[:client_name]}
                  item[:category] = []
                  result.push(item)
                end
                item[:category].push({name: assigned_category[:category_name], cm_id: assigned_category[:cm_id]})
              end

              {"data": result}
            end # End of assigned

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
                    optional :background, type: String, desc: 'Background color'
                    optional :is_member_report, type: Boolean, desc: 'Allow member to run report'
                    optional :member_roles, type: Array, desc: 'Member roles' do
                        requires :member_id, type: Integer, desc: 'Member id'
                        requires :is_pm, type: Boolean, desc: 'If member becomes Project Manager'
                    end
                    optional :category_members, type: Array, desc: 'Assign member to categories' do
                        requires :category_name, type: String, desc: 'Category name'
                        requires :is_billable, type: Boolean, desc: 'Billable'
                        requires :members, type: Array, desc: 'Member' do
                            requires :member_id, type: Integer, desc: 'Member id'
                        end
                    end
                end
            end
            post '/' do
              @current_member = Member.find(1)
              project_params = params[:project]

              # Current user has to be an admin or a PM
              if @current_member.role != 1 && @current_member.role != 2
                return error!(I18n.t("access_denied"), 400)
              end

              # Client has to belongs to the company of current user
              if !@current_member.company.clients.exists?(project_params[:client_id])
                return error!(I18n.t("client_not_found"), 400)
              end

              # Create new project object
              project = @current_member.projects.new

              # If background exists
              if project_params[:background]
                # Validate background here
                project.background = project_params[:background]
              end

              # If member_roles exists
              if project_params[:member_roles]
                project_params[:member_roles].each do |member_role|
                  # Check if member belongs to team
                  if !@current_member.company.members.exists?(member_role[:member_id])
                    return error!(I18n.t("not_joined_to_company"), 400)
                  end
                  # Add member in team to project
                  project.project_members.new(member_id: member_role[:member_id], is_pm: member_role[:is_pm])
                end

                # If category_members exists
                if project_params[:category_members]
                    project_params[:category_members].each do |category_member|
                      # Create new categories
                      category = project.categories.new(
                        name: category_member[:category_name],
                        is_billable: category_member[:is_billable]
                      )
                      #Check if company members were added to project
                      category_member[:members].each do |member|
                        if !project.project_members.find { |h| h[:member_id] == member[:member_id] }
                          return error!(I18n.t("not_added_to_project"), 400)
                        end
                        # Assign members to categories
                        category.category_members.new(member_id: member[:member_id])
                      end
                    end
                  end
                end

                project.name = project_params[:name]
                project.client_id = project_params[:client_id]

                if project_params[:is_member_report]
                  project.is_member_report = project_params[:is_member_report]
                end

                project.save!
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
