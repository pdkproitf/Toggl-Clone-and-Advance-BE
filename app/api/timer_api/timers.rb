module TimerApi
    class Timers < Grape::API
        prefix :api
        version 'v1', using: :accept_version_header

        helpers TimerHelper

        resource :timers do
            # => /api/v1/timers/
            desc 'Get all timers in period time'
            params do
                requires :period, type: Hash do
                    requires :from_day, type: Date, desc: 'From day'
                    requires :to_day, type: Date, desc: 'To day'
                end
            end
            get do
                authenticated!
                from_day = params[:period][:from_day]
                to_day = params[:period][:to_day]

                if from_day > to_day
                    return error!(I18n.t('from_to_day_error'), 400)
                end

                timer_list = @current_member.timers
                                            .where('timers.start_time >= ? AND timers.start_time < ?', from_day, to_day + 1)
                                            .order('start_time desc')

                data = {}
                date_list = []
                timer_list.each do |timer|
                    unless date_list.include?(timer.start_time.to_date.to_s)
                        date_list.push(timer.start_time.to_date.to_s)
                        data[timer.start_time.to_date.to_s] = []
                    end
                    data[timer.start_time.to_date.to_s].push(TimerSerializer.new(timer))
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
                authenticated!
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
                                name: timer_params[:task_name],
                                category_member_id: timer_params[:category_member_id]
                            )
                        end
                    else # category_member_id does not exist
                        category_member = @current_member.category_members.create!
                        task = category_member.tasks.create!(name: timer_params[:task_name])
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
                    requires :start_time, type: DateTime, desc: 'Start time'
                    requires :stop_time, type: DateTime, desc: 'Stop time'

                    optional :task_id, type: Integer, desc: 'Task ID'
                    optional :task_name, type: String, desc: 'Task Name'

                    requires :category_member_id, type: Integer, desc: "Member-Category's ID"
                    requires :project_id, type: Integer, desc: 'Current Project id'

                    exactly_one_of :task_id, :task_name
                end
            end
            put ':id' do
                authenticated!
                @timer = Timer.find(params['id'])
                return return_message "Error Not Allow for #{@current_member.user.email}" unless (@timer.task.category_member.member_id == @current_member.id)
                @category_member = @timer.task.category_member
                return modify_with_project
            end

            desc 'Delete Timer'
            delete ':id' do
                authenticated!
                status 200

                @timer = Timer.find(params['id'])
                return return_message "Error Not Allow for #{@current_member.user.email}" unless @timer.task.category_member.member_id == @current_member.id
                @timer.destroy!
                return_message 'Success'
            end
        end
    end
end
