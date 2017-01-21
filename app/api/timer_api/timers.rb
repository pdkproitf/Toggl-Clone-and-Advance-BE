module TimerApi
    class Timers < Grape::API
        prefix :api
        version 'v1', using: :accept_version_header
        #
        helpers do
        end

        resource :timers do
            # => /api/v1/timers/
            desc 'create new timer'
            params do
                requires :timer, type: Hash do
                    optional :task_id, type: Integer, desc: 'Task ID'
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
        end
    end
end
