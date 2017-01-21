module TaskApi
    class Tasks < Grape::API
        prefix :api
        version 'v1', using: :accept_version_header
        #
        helpers do
        end

        resource :tasks do
            # => /api/v1/tasks/
            desc 'create new task'
            params do
                requires :task, type: Hash do
                    optional :name, type: String, desc: 'Task name'
                    optional :project_category_user_id, type: Integer, desc: 'Project category user ID'
                end
            end
            post '/new' do
                task_params = params['task']
                begin
                    task = Task.create!(
                        name: task_params['name'],
                        project_category_user_id: task_params['project_category_user_id']
                    )
                rescue => e
                    { error: 'project category user must exist' }
                end
                # task
            end
        end
    end
end
