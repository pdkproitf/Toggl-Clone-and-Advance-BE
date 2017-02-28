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
                               .where(category_members: { is_archived: false })
                               .where.not(category_members: { category_id: nil })
                               .where.not(tasks: { name: '' })
                               .order('start_time desc')
                               .limit(params[:number])
            end
        end
    end
end
