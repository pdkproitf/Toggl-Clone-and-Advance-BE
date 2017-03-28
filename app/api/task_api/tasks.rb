module TaskApi
  class Tasks < Grape::API
    prefix :api
    version 'v1', using: :accept_version_header

    resource :tasks do
      # => /api/v1/tasks/
      desc 'Get all clients'
      params do
        requires :number, type: Integer, desc: 'Number of recent tasks you want to get'
      end
      get 'recent' do
        authenticated!
        unique_tasks = Task.joins(:timers, category_member: { project_member: :member })
                           .where(members: { id: @current_member.id })
                           .where.not(tasks: { name: '' })
                           .where.not(category_members: { category_id: nil, is_archived: true })
                           .select('DISTINCT ON (tasks.id) tasks.*, category_members.id as category_member_id')
                           .select('timers.id as timer_id, timers.stop_time')

        recent_tasks = Task.from("(#{unique_tasks.to_sql}) as unique_tasks")
                           .select('unique_tasks.*')
                           .order('unique_tasks.stop_time DESC').limit(params[:number])

        { data: ActiveModelSerializers::SerializableResource.new(recent_tasks, each_serializer: RecentTaskSerializer) }
      end
    end
  end
end
