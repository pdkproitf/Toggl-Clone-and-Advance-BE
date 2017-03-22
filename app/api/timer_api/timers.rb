module TimerApi
    class Timers < Grape::API
        prefix :api
        version 'v1', using: :accept_version_header

        helpers TimerHelper

        resource :timers do
            before do
                authenticated!
            end

            # => /api/v1/timers/
            desc 'Get all timers in period time'
            params do
                requires :period, type: Hash do
                    requires :from_day, type: Date, desc: 'From day'
                    requires :to_day, type: Date, desc: 'To day'
                end
            end
            get do
                # authenticated!
                from_day = params[:period][:from_day]
                to_day = params[:period][:to_day]

                return error!(I18n.t('from_to_day_error'), 400) if from_day > to_day

                timer_list = @current_member
                .timers
                .where(category_members: { is_archived_by_category: false })
                .where(category_members: { is_archived_by_project_member: false })
                .where('timers.start_time >= ? AND timers.start_time < ?',
                from_day, to_day + 1)
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

            desc 'Create new timer'
            params do
                requires :timer, type: Hash do
                    optional :task_id, type: Integer, desc: 'Timer ID'
                    optional :task_name, type: String, desc: 'Task name'
                    optional :category_member_id, type: Integer, desc: 'CategoryMember ID'
                    requires :start_time, type: DateTime, desc: 'Start time'
                    requires :stop_time, type: DateTime, desc: 'Stop time'
                end
            end
            post do
                # authenticated!
                timer_params = params['timer']
                if timer_params[:start_time] >= timer_params[:stop_time]
                    return error!(I18n.t('start_stop_time_error'), 400)
                end

                # if task_id exists
                if timer_params[:task_id]
                    # Check task_id belong to current member
                    task = @current_member.tasks.find_by_id(timer_params[:task_id])
                    return error!(I18n.t('not_found', title: "Task"), 404) if task.nil?

                    # if task name exists and is not blank
                elsif timer_params[:task_name] && !timer_params[:task_name].blank?
                    if timer_params[:category_member_id] # if category_member_id exists
                        category_member = @current_member
                        .category_members
                        .where.not(category_id: nil)
                        .find_by(
                        id: timer_params[:category_member_id],
                        is_archived_by_category: false,
                        is_archived_by_project_member: false
                        )
                        # if category member does not belong to any category
                        if category_member.nil?
                            return error!(I18n.t('member_not_assigned_to_category'), 400)
                        end

                        task = @current_member.tasks.find_by(
                        name: timer_params[:task_name],
                        category_member: category_member.id
                        )

                        # if cannot find and task then create new task
                        if task.nil?
                            task = Task.create!(
                            name: timer_params[:task_name],
                            category_member_id: category_member.id
                            )
                        end
                    else # category_member_id does not exist
                        project_member = @current_member.project_members.create!
                        category_member = project_member.category_members.create!
                        task = category_member.tasks.create!(name: timer_params[:task_name])
                    end

                    # Only start_time and stop_time
                    # Maybe category_member_id exists, or maybe task_name blank
                else
                    if timer_params[:category_member_id]
                        category_member = @current_member
                        .category_members
                        .where.not(category_id: nil)
                        .find_by(
                        id: timer_params[:category_member_id],
                        is_archived_by_category: false,
                        is_archived_by_project_member: false
                        )
                        # if category member does not belong to any category
                        if category_member.nil?
                            return error!(I18n.t('member_not_assigned_to_category'), 400)
                        end

                        task = Task.create!(
                        category_member_id: category_member.id
                        )
                    else # Only start_time and stop_time
                        project_member = @current_member.project_members.create!
                        category_member = project_member.category_members.create!

                        task = category_member.tasks.create!
                    end
                end
                unless task.nil?
                    task.timers.create!(start_time: timer_params[:start_time],
                    stop_time: timer_params[:stop_time])
                end
            end

            desc 'Edit timer'
            params do
                requires :timer_update, type: Hash do
                    requires :start_time, type: DateTime, desc: 'Start time'
                    requires :stop_time, type: DateTime, desc: 'Stop time'

                    optional :task_id, type: Integer, desc: 'Task ID'
                    optional :task_name, type: String, desc: 'Task Name'

                    optional :category_member_id, type: Integer, desc: "Member-Category's ID"

                    exactly_one_of :task_id, :task_name
                end
            end
            put ':id' do
                @timer = Timer.find(params['id'])
                error!(I18n.t("access_denied"), 403) unless
                    @timer.task.category_member.project_member.member_id == @current_member.id

                @category_member = CategoryMember.find_by_id(params['timer_update']['category_member_id'])
                error!(I18n.t("not_found", title: params['timer_update']['category_member_id']), 404) unless @category_member
                error!(I18n.t("access_denied"), 403) unless category_member_access?

                @category_member.id == @timer.task.category_member.id ? modify_with_task : modify_with_category_member
                return_message I18n.t("success"), TimerSerializer.new(@timer)
            end

            desc 'Delete Timer'
            delete ':id' do
                status 200

                @timer = Timer.find(params['id'])
                error!("access_denied") unless @timer.task.category_member.project_member.member_id == @current_member.id

                @timer.destroy!
                detelte_timer #destroy timer with_relationship_self
                return_message I18n.t("success")
            end
        end
    end
end
