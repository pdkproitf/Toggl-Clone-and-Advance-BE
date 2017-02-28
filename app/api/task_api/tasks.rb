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
                @current_member.timers
                               .where('category_members.category_id IS ?', nil)
                               .where('tasks.name != ?', '')
                               .order('start_time desc')
            end
        end
    end
end
