module ProjectApi
  # API for project
  class Projects < Grape::API
    prefix :api
    version 'v1', using: :accept_version_header

    # => /api/v1/projects/
    resource :projects do
      before do
        authenticated!
      end

      desc 'Get all projects current_member manage'
      get do
        projects = @current_member.get_projects.order('id desc')
        { data: ActiveModelSerializers::SerializableResource.new(projects, each_serializer: ProjectSerializer) }
      end

      desc 'Get all projects that I assigned'
      get 'assigned' do
        assigned_categories = @current_member.assigned_categories
        result = []
        assigned_categories.each do |ass_cat|
          item = result.find { |h| h[:id] == ass_cat[:project_id] }
          if item.blank?
            item = { id: ass_cat[:project_id], name: ass_cat[:project_name] }
            item[:background] = ass_cat[:background]
            item[:client] = { id: ass_cat[:client_id], name: ass_cat[:client_name] }
            item[:category] = []
            result.push(item)
          end
          item[:category].push(name: ass_cat[:category_name], category_member_id: ass_cat[:category_member_id])
        end
        { data: result }
      end # End of assigned

      desc 'Get a project by id'
      get ':id' do
        project = @current_member.get_projects.find(params[:id])
        { data: ProjectSerializer.new(project, categories_serialized: true) }
      end

      desc 'Create new project'
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
      post do
        project_params = params[:project]
        # Only Admin or Super PM has right to add new project
        return error!(I18n.t('access_denied'), 403) if !@current_member.admin? && !@current_member.pm?
        client = @current_member.company.clients.find(project_params[:client_id])

        # Create new project
        Project.transaction do
          project = @current_member.projects.new
          project.name = project_params[:name]
          project.client_id = client.id
          project.background = project_params[:background] if project_params[:background].present?
          project.is_member_report = project_params[:is_member_report] if project_params[:is_member_report].present?

          # Add members to project
          if project_params[:member_roles].present?
            project_params[:member_roles].each do |member_role|
              member = @current_member.company.members.find(member_role[:member_id])
              project.project_members.new(member_id: member.id, is_pm: member_role[:is_pm])
            end
          end
          project.save!

          # Create new categories and assign members to them
          if project_params[:category_members].present?
            Category.transaction do
              project_params[:category_members].each do |category_member|
                # Create new categories
                category = project.categories.new(name: category_member[:category_name], is_billable: category_member[:is_billable])
                # Assign members to categories
                category_member[:members].each do |member|
                  project_member = project.project_members.find_by!(member_id: member.member_id)
                  category.category_members.new(project_member_id: project_member.id)
                end
                category.save!
              end
            end # End of Category transaction
          end
          project
        end # End of Project transaction
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
        project_params = params[:project]
        project = @current_member.get_projects.find(params[:id])
        client = @current_member.company.clients.find(project_params[:client_id])
        Project.transaction do
          #  Update basic information
          name = project_params[:name]
          background = project_params[:background] if project_params[:background].present?
          is_member_report = project_params[:is_member_report] if project_params[:is_member_report].present?
          project.update_info(name, client, background: background, is_member_report: is_member_report)
          #  Update members of project
          project.update_members(project_params[:members]) unless project_params[:members].nil?
          #  Update categories
          project.update_categories(project_params[:categories]) unless project_params[:categories].nil?
        end # End of Project transaction
        { data: ProjectSerializer.new(project, categories_serialized: true) }
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
