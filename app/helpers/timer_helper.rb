module TimerHelper
    def modify_with_category_member
        @old_category_member_empty = nil
        if @category_member.category
            return return_message "Error Not Allow, #{@category_member.category.name} has been archived" unless access_to_category?
            return return_message "Error Not Allow, project  #{@category_member.category.project.name} has been archived or you no longer able to access" unless access_to_project? (@category_member.category.project)

            modify_with_category_member_exist_category
        else
            modify_with_category_member_empty_category
        end
    end

    def modify_with_category_member_exist_category
        @old_category_member_empty = @timer.task.category_member
        modify_with_task
    end

    def modify_with_category_member_empty_category
        return return_message 'Nothing for update' unless @timer.task.category_member.category
        @category_member =  @current_member.category_member.create!()
        create_new_task
    end

    def modify_with_task
        params['timer_update']['task_id']? update_exist_task : create_new_task
    end

    def update_exist_task
        task = @category_member.tasks.find_by_id(params['timer_update']['task_id'])
        return return_message "Task Not Found for #{@current_member.user.email}" unless task

        update_timer task
    end

    def create_new_task
        Task.transaction do
            task = @category_member.tasks.create!(name: params['timer_update']['task_name'])
            update_timer task
        end
    end

    def update_timer task
        @timer.task_id = task.id
        @timer.start_time = params['timer_update']['start_time']
        @timer.stop_time = params['timer_update']['stop_time']

        @timer.save!

        @old_category_member_empty.destroy! unless @old_category_member_empty.category
        return_message 'Sucess', TimerSerializer.new(@timer)
    end

    # true if you be member of project and project have not archived yet
    def access_to_project?(project)
        !project.is_archived && !project.project_members.find_by_member_id(@current_member.id).nil?
    end

    #true if category have not archived yet
    def access_to_category?
        !@category_member.category.is_archived
    end

    def access_to_category_member?
        (@category_member.member_id == @current_member.id) && !@category_member.is_archived
    end

    def access_to_task_under_pro_cate_member? task
        task.category_member_id = @category_member.id
    end

    def detelte_timer_with_relationship_self
        if @timer.task.category_member.category
            @timer.task.destroy! if @timer.task.timers.where.not(id: @timer.id) == 0
        else
            @timer.task.category_member.destroy!
        end
    end
end
