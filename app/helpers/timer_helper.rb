module TimerHelper
    def update_timer task
        @timer.task_id = task.id
        @timer.start_time = params['timer_update']['start_time']
        @timer.stop_time = params['timer_update']['stop_time']

        @timer.save!

        return_message 'Sucess', TimerSerializer.new(@timer)
    end

    # check project you be apply or project you create
    def access_to_project?(project)
        project.project_members.find_by_member_id(@current_member.id)
    end

    # true if you have category_member
    def access_to_category_under_project?(category_member, project)
        return false unless category_member.member_id == @current_member.id
        project.categories.find_by_id(category_member.category_id)
    end

    # true if task of current_project_category_user
    def access_to_task_under_pro_cate_user? task
        return task.category_member_id == @category_member.id
    end

    def modify_with_project
        project = Project.find_by_id(params['timer_update']['project_id'])
        return return_message "Error Project Not Found for #{@current_member.user.email}"  unless project
        return return_message "Error Project Not Allow for #{@current_member.user.email}"  unless access_to_project? project

        modify_with_category_member  project
    end

    def modify_with_category_member(project)
        category_member = CategoryMember.find_by_id(params['timer_update']['category_member_id'])
        return return_message "Category Not Found for #{@current_member.user.email}" unless category_member
        return return_message "Category Not Allow for #{@current_member.user.email}" unless access_to_category_under_project? category_member, project

        modify_with_task
    end

    def modify_with_task
        params['timer_update']['task_id']? update_exist_task : create_new_task
    end

    def update_exist_task
        task = Task.find_by_id(params['timer_update']['task_id'])
        return return_message "Task Not Found for #{@current_member.user.email}" unless task
        return return_message "Task Not Allow for #{@current_member.user.email}" unless access_to_task_under_pro_cate_user? task

        update_timer task
    end

    def create_new_task
        Task.transaction do
            task = @category_member.tasks.create!(name: params['timer_update']['task_name'])
            update_timer task
        end
    end

end
