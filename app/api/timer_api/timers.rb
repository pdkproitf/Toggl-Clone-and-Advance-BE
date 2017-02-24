module TimerApi
    class Timers < Grape::API
        prefix :api
        version 'v1', using: :accept_version_header
        #
        helpers do
            def update_timer(task)
                @timer.task_id = task.id
                @timer.start_time = params['timer_update']['timer']['start_time']
                @timer.stop_time = params['timer_update']['timer']['stop_time']

                @timer.save!

                return_message 'Sucess', @timer
            end

            def update_task(task)
                task.project_category_user_id = @project_category_user.id
                task.name = params['timer_update']['task']['task_name']
                task.save!

                update_timer task
            end

            # check project you be apply or project you create
            def access_to_project?(project)
                return true if @current_user.project_user_roles.find_by(project_id: project.id) || @current_user.projects.find_by_id(project.id)
                false
            end

            # true if you have project_category_user of this category
            def access_to_category_under_project?(category, project)
                project_category = project.project_categories.find_by(category_id: category.id)
                @project_category_user = @current_user.project_category_users.find_by(project_category_id: project_category.id)
                return true if @project_category_user
                false
            end

            # true if task of current_project_category_user
            def access_to_task_under_pro_cate_user?(task, pcu)
                return true if task.project_category_user_id == pcu.id
                false
            end

            def modify_with_project
                project = Project.find_by_id(params['timer_update']['project_id'])
                return return_message "Error Project Not Found for #{@current_user.email}"  unless project
                return return_message "Error Project Not Allow for #{@current_user.email}"  unless access_to_project? project

                modify_with_category  project
            end

            def modify_with_category(project)
                category = Category.find_by_id(params['timer_update']['category_id'])
                return return_message "Category Not Found for #{@current_user.email}" unless category
                return return_message "Category Not Allow for #{@current_user.email}" unless access_to_category_under_project? category, project

                modify_with_task
            end

            def modify_with_task
                task = Task.find_by_id(params['timer_update']['task']['task_id'])
                return return_message "Task Not Found for #{@current_user.email}" unless task
                return return_message "Task Not Allow for #{@current_user.email}" unless access_to_task_under_pro_cate_user? task, @project_category_user

                update_task task
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

                timer_list = Timer.left_outer_joins(task: { project_category_user: { project_category: [:project, :category] } })
                                  .where(project_category_users: { user_id: @current_user.id })
                                  .where('timers.start_time >= ? AND timers.start_time < ?', from_day, to_day + 1)
                                  .select('timers.id', 'timers.start_time', 'timers.stop_time')
                                  .select('tasks.id as task_id', 'tasks.name as task_name', 'tasks.project_category_user_id as pcu_id')
                                  .select('projects.name as project_name', 'categories.name as category_name')
                                  .order('timers.start_time asc')

                data = {}
                date_list = []
                timer_list.each do |timer|
                    unless date_list.include?(timer.start_time.to_date.to_s)
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
                    optional :category_member_id, type: Integer, desc: 'Category member ID'
                    requires :start_time, type: DateTime, desc: 'Start time'
                    requires :stop_time, type: DateTime, desc: 'Stop time'
                end
            end
            post '/' do
                @current_member = Member.find(1)
                timer_params = params['timer']
                if timer_params[:start_time] >= timer_params[:stop_time]
                    return error!(I18n.t('start_stop_time_error'), 400)
                end

                # if task_id exists
                if timer_params[:task_id]
                    # Check task_id belong to current member
                    task = @current_member.tasks.find_by_id(timer_params[:task_id])
                    return error!(I18n.t('task_not_found'), 404) if task.nil?
                elsif timer_params[:task_name] # if task name exists
                    if timer_params[:category_member_id] # if category_member_id exists
                        # if category_member does not belong to current_member
                        task = @current_member.tasks.find_by(
                            name: timer_params[:task_name],
                            category_member: timer_params[:category_member_id]
                        )
                        if task.nil?
                            unless @current_member.category_members.exists?(timer_params[:category_member_id])
                                return error!(I18n.t('member_not_assigned_to_category'), 400)
                            end
                            task = Task.create!(
                                name: timer_params[:name],
                                category_member_id: timer_params[:category_member_id]
                            )
                        end
                    else # category_member_id does not exist
                        category_member = @current_member.category_members.create!
                        task = category_member.tasks.create!(name: timer_params[:name])
                    end
                else # Only start_time and stop_time (maybe category_member_id exists)
                    if timer_params[:category_member_id]
                        unless @current_member.category_members.exists?(timer_params[:category_member_id])
                            return error!(I18n.t('member_not_assigned_to_category'), 400)
                        end
                        task = Task.create!(
                            category_member_id: timer_params[:category_member_id]
                        )
                    else # Only start_time and stop_time
                        category_member = @current_member.category_members.create!
                        task = category_member.tasks.create!
                    end
                end

                task.timers.create!(
                    start_time: timer_params['start_time'],
                    stop_time: timer_params['stop_time']
                )
            end

            desc 'Edit timer'
            params do
                requires :timer_update, type: Hash do
                    requires :timer, type: Hash do
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
                return return_message "Error Not Allow for #{@current_user.email}" unless @timer.task.project_category_user.user_id == @current_user.id
                @project_category_user = @timer.task.project_category_user
                return modify_with_project
            end

            desc 'Delete Timer'
            delete ':id' do
                authenticated!
                status 200

                @timer = Timer.find(params['id'])
                return return_message "Error Not Allow for #{@current_user.email}" unless @timer.task.project_category_user.user_id == @current_user.id
                @timer.destroy!
                return_message 'Success'
            end
        end
    end
end
