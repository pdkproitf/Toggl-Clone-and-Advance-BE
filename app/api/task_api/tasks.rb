module TaskApi
    class Tasks < Grape::API
        prefix :api
        version 'v1', using: :accept_version_header
        #
        helpers do
        end

        resource :tasks do
            # => /api/v1/tasks/
            desc 'Get all clients'
            params do
                requires :number, type: Integer, desc: 'Number of recent tasks you want to get'
            end
            get 'recent' do
                authenticated!
                timers = @current_member.timers
                                        .where(category_members: { is_archived: false })
                                        .where.not(category_members: { category_id: nil })
                                        .where.not(tasks: { name: '' })
                                        .limit(params[:number])
                                        .select('DISTINCT tasks.id as task_id', 'tasks.name as task_name')
                                        .select('tasks.created_at', 'tasks.updated_at', 'tasks.category_member_id')
                                        .select('start_time')
                                        .order('start_time desc')

                result = []
                timers.each do |timer|
                    task = Task.new(id: timer.task_id, name: timer.task_name)
                    task[:category_member_id] = timer.category_member_id
                    task[:created_at] = timer.created_at
                    task[:updated_at] = timer.updated_at
                    result.push(RecentTaskSerializer.new(task))
                end
                { data: result }
            end
        end
    end
end
