module TimerApi
    class Timers < Grape::API
        prefix :api
        version 'v1', using: :accept_version_header
        #
        helpers do
        end

        resource :timers do
            # => /api/v1/timers/
            desc 'Get all timers'
            get '/all' do
                user = User.find(1)
                pcu_list = user.project_category_users
                timer_list = [];
                pcu_list.each do |pcu|
                  task_list = pcu.tasks
                  task_list.each do |task|
                    timers = task.timers
                    timers.each do |timer|
                      timer = TimerSerializer.new(timer)
                        timer_list.push(timer)
                    end
                  end
                end
            {"data": timer_list}
            end

            desc 'create new timer'
            params do
                requires :timer, type: Hash do
                    optional :task_id, type: Integer, desc: 'Timer ID'
                    requires :start_time, type: DateTime, desc: 'Start time'
                    requires :stop_time, type: DateTime, desc: 'Stop time'
                end
            end
            post '/new' do
                timer_params = params['timer']
                if timer_params['task_id'] && !timer_params['task_id'].nil?
                    task_id_param = timer_params['task_id']
                else
                    pcu = ProjectCategoryUser.create!(
                        user_id: 1
                    )
                    task = Task.create!(
                        project_category_user_id: pcu.id
                    )
                    task_id_param = task.id
                end
                timer = Timer.create!(
                    task_id: task_id_param,
                    start_time: timer_params['start_time'],
                    stop_time: timer_params['stop_time']
                )
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
                timer_params = params['timer']
                timer = Timer.find(params['id'])
                begin
                    timer.update(
                        task_id: timer_params['task_id'],
                        start_time: timer_params['start_time'],
                        stop_time: timer_params['stop_time']
                    )
                rescue => e
                    { error: 'Task must exist' }
                end
                task
            end
        end
    end
end
