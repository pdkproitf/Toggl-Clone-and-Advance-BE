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
          requires :from_day, type: DateTime, desc: 'From day'
          requires :to_day, type: DateTime, desc: 'To day'
        end
      end
      get do
        return error!(I18n.t('from_to_day_error'), 400) if params[:period][:from_day] > params[:period][:to_day]
        timers = @current_member.get_timers(params[:period][:from_day], params[:period][:to_day])

        date = {}
        timers.each do |timer|
          date[timer.start_time.to_date.to_s] = [] if date[timer.start_time.to_date.to_s].nil?
          date[timer.start_time.to_date.to_s].push(TimerSerializer.new(timer))
        end
        date
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
        timer_params = params['timer']
        return error!(I18n.t('start_stop_time_error'), 400) if timer_params[:start_time] >= timer_params[:stop_time]
        # Check if task_id present
        if timer_params[:task_id].present?
          # Check task_id belong to current member
          task = @current_member.tasks.find(timer_params[:task_id])
        elsif timer_params[:task_name].present?
          if timer_params[:category_member_id].present? # if category_member_id exists
            category_member = @current_member
                              .category_members.where.not(category_id: nil)
                              .find_by!(id: timer_params[:category_member_id], is_archived: false)
            # Find task by name and category_member
            task = @current_member.tasks.find_by(name: timer_params[:task_name], category_member_id: category_member.id)
            # If task not found then create new one
            task = Task.create!(name: timer_params[:task_name], category_member_id: category_member.id) if task.blank?
          else # category_member_id does not exist then create and add member to fake project
            task = @current_member.new_fake_task(timer_params[:task_name])
          end
        else # Only start_time and stop_time. Maybe category_member_id exists, or maybe task_name blank
          if timer_params[:category_member_id]
            category_member = @current_member
                              .category_members.where.not(category_id: nil)
                              .find_by!(id: timer_params[:category_member_id], is_archived: false)
            task = Task.create!(category_member_id: category_member.id)
          else # Only start_time and stop_time
            task = @current_member.new_fake_task
          end
        end
        if task.present?
          task.timers.create!(start_time: timer_params[:start_time], stop_time: timer_params[:stop_time])
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
        error!(I18n.t('access_denied'), 403) unless
            @timer.task.category_member.project_member.member_id == @current_member.id

        @category_member = CategoryMember.find_by_id(params['timer_update']['category_member_id'])
        error!(I18n.t('not_found', title: params['timer_update']['category_member_id']), 404) unless @category_member
        error!(I18n.t('access_denied'), 403) unless category_member_access?

        @category_member.id == @timer.task.category_member.id ? modify_with_task : modify_with_category_member
        return_message I18n.t('success'), TimerSerializer.new(@timer)
      end

      desc 'Delete Timer'
      delete ':id' do
        status 200

        @timer = Timer.find(params['id'])
        error!('access_denied') unless @timer.task.category_member.project_member.member_id == @current_member.id

        @timer.destroy!
        detelte_timer # destroy timer with_relationship_self
        return_message I18n.t('success')
      end
    end
  end
end
