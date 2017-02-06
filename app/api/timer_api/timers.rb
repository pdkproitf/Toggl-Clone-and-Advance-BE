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
                Timer.all
            end

            desc 'create new timer'
            params do
                requires :timer, type: Hash do
                    requires :task_id, type: Integer, desc: 'Timer ID'
                    requires :start_time, type: DateTime, desc: 'Start time'
                    requires :stop_time, type: DateTime, desc: 'Stop time'
                end
            end
            post '/new' do
                timer_params = params['timer']
                begin
                    timer = Timer.create!(
                        task_id: timer_params['task_id'],
                        start_time: timer_params['start_time'],
                        stop_time: timer_params['stop_time']
                    )
                rescue => e
                    { error: 'Task must exist' }
                end
                # task
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
