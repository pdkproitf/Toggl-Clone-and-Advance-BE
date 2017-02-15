module TimerApi
    class Timers < Grape::API
        prefix :api
        version 'v1', using: :accept_version_header
        #
        helpers do
            # Check project_category_user_id belong to the current user
            def is_project_category_current_user(pcu_id)
                is_belong = false
                if ProjectCategoryUser.exists? id: pcu_id
                    pcu = ProjectCategoryUser.find(pcu_id)
                    is_belong = true if pcu.user_id == @current_user.id
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
                    optional :project_category_user_id, type: Integer, desc: 'Project Category ID'
                    requires :start_time, type: DateTime, desc: 'Start time'
                    requires :stop_time, type: DateTime, desc: 'Stop time'
                end
            end
            post '/' do
                authenticated!
                timer_params = params['timer']

                # If there is task_id
                # if timer_params['task_id']
                #     # Check task_id belong to current user
                #     if Task.find(timer_params['task_id']).project_category_user.user_id == @current_user.id
                #         task_id = timer_params['task_id']
                #     else
                #         return error!(I18n.t('task_not_found'), 404)
                #     end
                # elsif timer_params['task_name'] # Have task name
                #     task_name = timer_params['task_name']
                #     if timer_params['project_category_user_id'] # Have project_category_user_id
                #         pcu_id = timer_params['project_category_user_id']
                #         if is_project_category_current_user pcu_id
                #             if Task.exists?(name: task_name, project_category_user_id: pcu_id)
                #                 task = Task.find_by(name: task_name, project_category_user_id: pcu_id)
                #             else
                #                 task = Task.create!(
                #                     name: timer_params['task_name'],
                #                     project_category_user_id: pcu_id
                #                 )
                #             end
                #             task_id_param = task.id
                #         else
                #             return error!(I18n.t('not_project_category_current_user'), 404)
                #         end
                #     end
                # end
                #
                # if task_id
                #     task_id
                # else
                #     'Oops'
                # end

                # Have task_id
                if timer_params['task_id'] && !timer_params['task_id'].nil?
                  # Check task_id belong to current user
                  if Task.find(timer_params['task_id']).project_category_user.user_id == @current_user.id
                    task_id_param = timer_params['task_id']
                  end
                elsif timer_params['task_name'] # Have task name
                  task_name = timer_params['task_name']
                  if timer_params['project_category_user_id'] # Have project_category_user_id
                    pcu_id = timer_params['project_category_user_id']

                    if is_project_category_current_user pcu_id
                      if Task.exists?(:name => task_name, :project_category_user_id => pcu_id)
                        task = Task.find_by(name: task_name, project_category_user_id: pcu_id)
                      else
                        task = Task.create!(
                            name: timer_params['task_name'],
                            project_category_user_id: pcu_id
                        )
                      end
                      task_id_param = task.id
                    end
                  else # Have not project category user id
                    pcu = ProjectCategoryUser.create!(
                        user_id: @current_user.id
                    )
                    task = Task.create!(
                        name: timer_params['task_name'],
                        project_category_user_id: pcu.id
                    )
                    task_id_param = task.id
                  end
                else # Have not name
                  if timer_params['project_category_user_id'] # Have project_category_user_id
                    pcu_id = timer_params['project_category_user_id']
                    if is_project_category_current_user pcu_id
                      task = Task.create!(
                          project_category_user_id: timer_params['project_category_user_id']
                      )
                      task_id_param = task.id
                    end
                  else # Have nothing
                    pcu = ProjectCategoryUser.create!(
                        user_id: @current_user.id
                    )
                    task = Task.create!(
                        project_category_user_id: pcu.id
                    )
                    task_id_param = task.id
                  end
                end
                if task_id_param
                  timer = Timer.create!(
                      task_id: task_id_param,
                      start_time: timer_params['start_time'],
                      stop_time: timer_params['stop_time']
                  )
                else
                  status 400
                  {
                    "error": "Validation failed: Task must exist"
                  }
                end
            end

            desc 'edit a timer'
            params do
                requires :timer, type: Hash do
                    requires :task_id, type: Integer, desc: 'Timer ID'
                    requires :start_time, type: DateTime, desc: 'Start time'
                    requires :stop_time, type: DateTime, desc: 'Stop time'
                end
            end
            put ':id' do
                authenticated!
                timer_params = params['timer']
                timer = Timer.find(params['id'])
                if timer.task.project_category_user.user_id == @current_user.id
                    begin
                        timer.update(
                            task_id: timer_params['task_id'],
                            start_time: timer_params['start_time'],
                            stop_time: timer_params['stop_time']
                        )
                    rescue => e
                        { error: 'Task must exist' }
                    end
                    timer
                end
            end
        end
    end
end
