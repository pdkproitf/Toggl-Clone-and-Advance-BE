module TimerApi
    class Timers < Grape::API
        prefix :api
        version 'v1', using: :accept_version_header
        #
        helpers do
            def update_timer task
                @timer.task_id = task.id
                @timer.start_time = params['timer']['start_time']
                @timer.stop_time = params['timer']['stop_time']

                @timer.save!
            end

            def update_task task
                task.project_category_user_id = @project_category_user.id
                task.name = params['task']['task_name']
                task.save!

                update_timer task
            end

            def access_to_project? project
                return true if @current_user.project_user_roles.find_by(project_id: project.id)
                return false
            end

            def access_to_category_under_project? category, project
                project_category = project.project_categories.find_by(category_id: category.id)
                @project_category_user = @current_user.project_category_users.find_by(project_category_id: project_category.id)
                return true if @project_category_user
                return false
            end

            def access_to_task_under_pro_cate_user? task, pcu
                return true if task.project_category_user_id == pcu.id
                return false
            end

            def modify_with_project
                project = Project.find_by_id(params['project_id'])
                return return_message "Error Project Not Found for #{@current_user.email}"  unless project
                return return_message "Error Project Not Allow for #{@current_user.email}"  unless access_to_project? project

                return modify_with_category  project
            end

            def modify_with_category project
                category = Category.find_by_id(params['category']['category_id'])
                return return_message "Category Not Found for #{@current_user.email}" unless category
                return return_message "Category Not Allow for #{@current_user.email}" unless access_to_category_under_project? category, project

                return modify_with_task
            end

            def modify_with_task
                task = Task.find_by_id(params['task']['task_id'])
                return return_message "Task Not Found for #{@current_user.email}" unless Task
                return return_message "Task Not Allow for #{@current_user.email}" unless acsess_to_task_under_pro_cate_user? task, @project_category_user

                update_task task
            end

          # Check project_category_user_id belong to the current user
          def is_project_category_current_user pcu_id
            is_belong = false
            if ProjectCategoryUser.exists? id: pcu_id
              pcu = ProjectCategoryUser.find(pcu_id)
              if pcu.user_id == @current_user.id
                is_belong = true
              end
            end
            is_belong
          end

        end

        resource :timers do
            # => /api/v1/timers/
            desc 'Get all timers in period time'
            params do
                requires :period, type: Hash do
                    requires :from_day, type: Date, desc: 'From day'
                    requires :to_day, type: Date, desc: 'To day'
                end
            end
            get '/' do
              authenticated!
              from_day = params[:period][:from_day]
              to_day = params[:period][:to_day]
              # timer_list = Timer.joins(task: :project_category_user)
              # .where(project_category_users: { user_id: @current_user.id })
              # .where("timers.start_time >= ? AND timers.start_time < ?", from_day, to_day + 1)

              timer_list = Timer.left_outer_joins(task: {project_category_user: {project_category: [:project, :category]}})
              .where(project_category_users: { user_id: @current_user.id })
              .where("timers.start_time >= ? AND timers.start_time < ?", from_day, to_day + 1)
              .select("timers.*", "projects.name")

              data = {}
              date_list = []
              timer_list.each do |timer|
                if !date_list.include?(timer.start_time.to_date.to_s)
                  date_list.push(timer.start_time.to_date.to_s)
                  data[timer.start_time.to_date.to_s] = []
                end
                data[timer.start_time.to_date.to_s].push(timer)
              end
              data
            end

            desc 'create new timer'
            params do
                requires :timer, type: Hash do
                    optional :task_id, type: Integer, desc: 'Timer ID'
                    optional :task_name, type: String, desc: 'Task name'
                    optional :project_category_user_id, type: Integer, desc: 'Project Category ID'
                    requires :start_time, type: DateTime, desc: 'Start time'
                    requires :stop_time, type: DateTime, desc: 'Stop time'
                end
            end
            post '/new' do
                authenticated!
                timer_params = params['timer']

                # If there is task_id
                if timer_params['task_id']
                    # Check task_id belong to current user
                    if Task.find(timer_params['task_id']).project_category_user.user_id == @current_user.id
                        task_id = timer_params['task_id']
                    else
                        return error!(I18n.t('task_not_found'), 404)
                    end
                elsif timer_params['task_name'] # Have task name
                    task_name = timer_params['task_name']
                    if timer_params['project_category_user_id'] # Have project_category_user_id
                        pcu_id = timer_params['project_category_user_id']
                        if is_project_category_current_user pcu_id
                            if Task.exists?(name: task_name, project_category_user_id: pcu_id)
                                task = Task.find_by(name: task_name, project_category_user_id: pcu_id)
                            else
                                task = Task.create!(
                                    name: timer_params['task_name'],
                                    project_category_user_id: pcu_id
                                )
                            end
                            task_id = task.id
                        else
                            return error!(I18n.t('not_project_category_current_user'), 404)
                        end
                    else # Have not project_category_user_id
                        pcu = ProjectCategoryUser.create!(
                            user_id: @current_user.id
                        )
                        task = Task.create!(
                            name: timer_params['task_name'],
                            project_category_user_id: pcu.id
                        )
                        task_id = task.id
                    end
                else
                    if timer_params['project_category_user_id'] # Have project_category_user_id
                        pcu_id = timer_params['project_category_user_id']
                        if is_project_category_current_user pcu_id
                            task = Task.create!(
                                project_category_user_id: timer_params['project_category_user_id']
                            )
                            task_id = task.id
                        else
                            return error!(I18n.t('not_project_category_current_user'), 404)
                        end
                    else # Have nothing
                        pcu = ProjectCategoryUser.create!(
                            user_id: @current_user.id
                        )
                        task = Task.create!(
                            project_category_user_id: pcu.id
                        )
                        task_id = task.id
                    end
                end

                if task_id
                    timer = Timer.create!(
                        task_id: task_id,
                        start_time: timer_params['start_time'],
                        stop_time: timer_params['stop_time']
                    )
                    timer_result = Timer.left_outer_joins(task: { project_category_user: { project_category: [:project, :category] } })
                                        .where(id: timer.id)
                                        .select('timers.id', 'timers.start_time', 'timers.stop_time')
                                        .select('tasks.id as task_id', 'tasks.name as task_name', 'tasks.project_category_user_id as pcu_id')
                                        .select('projects.name as project_name', 'categories.name as category_name')
                                        .order('timers.start_time asc')

                    {"data": timer_result.first.as_json}
                else
                    return error!(I18n.t('task_not_found'), 404)
                end
            end # End of add new

            desc 'Edit timer'
            params do
                requires :timer_update, type: Hash do
                    requires :timer, type: Hash  do
                        requires :start_time, type: DateTime, desc: 'Start time'
                        requires :stop_time, type: DateTime, desc: 'Stop time'
                    end

                    optional :task, type: Hash do
                        requires :task_id, type: Integer, desc: 'Task ID'
                        requires :task_name, type: String, desc: 'Task Name'
                    end

                    optional :category, type: Hash do
                        requires :category_id, type: Integer, desc: 'Category ID'
                        requires :category_name, type: String, desc: 'Category Name'
                    end

                    requires :project_id, type: Integer, desc: 'Current Project id'
                end
            end
            put ':id' do
                authenticated!

                @timer = Timer.find(params['id'])
                begin
                    return return_message "Error Not Allow for #{@current_user.email}" unless @timer.task.project_category_user.user_id == @current_user.id
                    @project_category_user = @timer.task.project_category_user
                    return modify_with_project
                rescue e
                    p e
                    return_message "Error Not Found Timer for #{@current_user.email}"
                end
            end

            desc 'Delete Timer'
            delete ':id' do
                authenticated!
                status 200

                @timer = Timer.find(params['id'])
                begin
                    return return_message "Error Not Allow for #{@current_user.email}" unless @timer.task.project_category_user.user_id == @current_user.id
                    @timer.destroy!
                    return_message "Success"
                rescue e
                    p e
                    return_message "Error Not Found Timer for #{@current_user.email}"
                end
            end
        end
    end
end
