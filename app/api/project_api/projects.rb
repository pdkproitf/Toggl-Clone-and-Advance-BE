module ProjectApi
  # API for project
  class Projects < Grape::API
    prefix :api
    version 'v1', using: :accept_version_header
    resource :projects do
      # => /api/v1/projects/
      desc 'Get all projects that I own'
      get do
        authenticated!
        projects = @current_member.get_projects
                                  .where(is_archived: false).order('id desc')
        list = []
        projects.each do |project|
          list.push(ProjectSerializer.new(project))
        end
        { data: list }
        # return {members: Member.all.map{|p| MembersSerializer.new(p)}}
        # return {hehe: ProjectSerializer.new(Project.find(1))}
        # {"data": ProjectSerializer.new(Project.find(1))}
      end

      desc 'Get all projects that I assigned'
      get 'assigned' do
        # Get all projects, categories, category_members were not archived
        authenticated!
        assigned_categories =
          @current_member
          .category_members
          .where.not(category_id: nil)
          .where(projects: { is_archived: false })
          .where(categories: { is_archived: false })
          .where(category_members: { is_archived: false })
          .joins(category: { project: :client })
          .select('projects.id', 'projects.name', 'projects.background')
          .select('clients.id as client_id', 'clients.name as client_name')
          .select('categories.name as category_name')
          .select('category_members.id as category_member_id')
          .order('projects.id desc', 'categories.id asc')

        result = []
        assigned_categories.each do |assigned_category|
          # if current_member is archived in project (remove from project)
          if @current_member.project_members
                            .where(project_id: assigned_category.id)
                            .first.is_archived
            next
          end
          item = result.find { |h| h[:id] == assigned_category[:id] }
          unless item
            item = {
              id: assigned_category[:id],
              name: assigned_category[:name]
            }
            item[:background] = assigned_category[:background]
            item[:client] = {
              id: assigned_category[:client_id],
              name: assigned_category[:client_name]
            }
            item[:category] = []
            result.push(item)
          end
          item[:category].push(
            name: assigned_category[:category_name],
            category_member_id: assigned_category[:category_member_id]
          )
        end

        { data: result }
      end # End of assigned

      desc 'Get a project by id'
      get ':id' do
        authenticated!
        projects = @current_member.get_projects
                                  .where(id: params[:id], is_archived: false)

        return error!(I18n.t('project_not_found'), 404) if projects.empty?

        project = projects.first
        result = {}
        result.merge!(ProjectSerializer.new(project))
        result[:tracked_time] = project.get_tracked_time
        categories = []
        project.categories.each do |category|
          categories.push(CategorySerializer.new(category))
        end
        result[:categories] = categories
        { data: result }
      end # End of getting a project by ID (for details)

      desc 'create new project'
      params do
        requires :project, type: Hash do
          requires :name, type: String, desc: 'Project name.'
          requires :client_id, type: Integer, desc: 'Client id'
          optional :background, type: String, desc: 'Background color'
          optional :is_member_report, type: Boolean, desc: 'Member run report'
          optional :member_roles, type: Array, desc: 'Member roles' do
            requires :member_id, type: Integer, desc: 'Member id'
            requires :is_pm, type: Boolean, desc: 'Member as Project Manager'
          end
          optional :category_members, type: Array, desc: 'Member in category' do
            requires :category_name, type: String, desc: 'Category name'
            requires :is_billable, type: Boolean, desc: 'Billable'
            requires :members, type: Array, desc: 'Member' do
              requires :member_id, type: Integer, desc: 'Member id'
            end
          end
        end
      end
      post '/' do
        authenticated!
        project_params = params[:project]

        # Current user has to be an admin or a PM
        if !@current_member.admin? && !@current_member.pm?
          return error!(I18n.t('access_denied'), 400)
        end

        # Client has to belongs to the company of current user
        unless @current_member.company
                              .clients
                              .exists?(project_params[:client_id])
          return error!(I18n.t('client_not_found'), 400)
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
            unless @current_member.company
                                  .members
                                  .exists?(member_role[:member_id])
              return error!(I18n.t('not_joined_to_company'), 400)
            end
            # Add member in team to project
            project.project_members.new(
              member_id: member_role[:member_id],
              is_pm: member_role[:is_pm]
            )
          end

          # If category_members exists
          if project_params[:category_members]
            project_params[:category_members].each do |category_member|
              # Create new categories
              category = project.categories.new(
                name: category_member[:category_name],
                is_billable: category_member[:is_billable]
              )
              # Check if company members were added to project
              category_member[:members].each do |member|
                unless project.project_members
                              .find { |h| h[:member_id] == member[:member_id] }
                  return error!(I18n.t('not_added_to_project'), 400)
                end
                # Assign members to categories
                category.category_members.new(member_id: member[:member_id])
              end
            end
          end
        end

        project.name = project_params[:name]
        project.client_id = project_params[:client_id]

        unless project_params[:is_member_report].nil?
          project.is_member_report = project_params[:is_member_report]
        end

        project.save!
      end # End of project add new

      desc 'Edit project'
      params do
        requires :project, type: Hash do
          requires :name, type: String, desc: 'Project name.'
          requires :client_id, type: Integer, desc: 'Client id'
          optional :background, type: String, desc: 'Background color'
          optional :is_member_report, type: Boolean, desc: 'Member run report'
          optional :members, type: Array, desc: 'Members of project' do
            requires :id, type: Integer, desc: 'Member id'
            requires :is_pm, type: Boolean, desc: 'Member as Project Manager'
          end
          optional :categories, type: Array, desc: 'Categories' do
            requires :id, type: Integer, desc: 'Category ID'
            requires :name, type: String, desc: 'Category name'
            requires :is_billable, type: Boolean, desc: 'Billable or not'
            requires :member_ids, type: Array[Integer], desc: 'Member IDs'
          end
        end
      end
      put ':id' do
        authenticated!
        project_params = params[:project]
        project = @current_member.get_projects.find_by(id: params[:id])
        error!(I18n.t('project_not_found'), 400) unless project
        # ***************** Edit basic information ***************************
        # Edit project name
        project.name = project_params[:name]
        # Edit client
        client = @current_member.company
                                .clients
                                .find_by(id: project_params[:client_id])
        return error!(I18n.t('client_not_found'), 400) unless client
        project.client = client
        # Edit background
        unless project_params[:background].nil?
          project.background = project_params[:background]
        end
        # Edit report permission
        unless project_params[:is_member_report].nil?
          project.is_member_report = project_params[:is_member_report]
        end
        # ***************** Edit basic information ends **********************
        # ******************** Edit members of project ***********************
        members = project_params[:members]
        unless members.nil?
          member_ids = []
          members.each do |member|
            member_ids.push(member.id)
            existing_member = project.project_members
                                     .find_by(member_id: member.id)
            if existing_member.nil?
              # Add new member to project
              new_member = @current_member.company
                                          .members
                                          .find_by(id: member.id)
              if new_member.nil?
                return error!(I18n.t('not_joined_to_company'), 400)
              end
              project.project_members.new(
                member_id: new_member.id,
                is_pm: member.is_pm
              )
            else
              # Edit existing member of project
              existing_member.unarchive
              existing_member[:is_pm] = member.is_pm
              existing_member.save!
            end
          end
          # Archive members were added to project before but not exist in params
          project.members_except_with(member_ids).each(&:archive)
        end
        # ****************** Edit members of project ends ********************
        # ************************* Edit categories **************************
        categories = project_params[:categories]
        category_ids = []
        unless categories.nil?
          categories.each do |category|
            category_ids.push(category.id)
            if category.id.nil?
              # Add new category
              if project.categories.find_by(name: category.name).nil?
                return error!(I18n.t('category_name_taken'), 400)
              end
              project.categories.new(
                name: category.name,
                is_billable: category.is_billable
              )
            else
              # Unarchive and change info of old category existing in params
              existing_category = project.categories
                                         .find_by(id: category.id)
              if existing_category.nil?
                return error!(I18n.t('category_not_found'), 400)
              end
              existing_category[:name] = category.name
              existing_category[:is_billable] = category.is_billable
              existing_category.save!
            end
          end
        end
        # Archive old category not existing in params
        project.categories_except_with(category_ids).each(&:archive)
        # ********************** Edit categories ends ************************
        project.save
      end # End of editing project

      desc 'Delete a project'
      delete ':id' do
        authenticated!
        status 200
        begin
          project = @current_user.projects.find(params[:id])
          project.destroy
          { 'message' => 'Delete project successfully' }
        rescue
          error!(I18n.t('project_not_found'), 400)
        end
      end
    end
  end
end
