module TimerHelper
    def modify_with_category_member
        @old_category_member_empty = nil
        if @category_member.category
            error!(I18n.t("archived", content: "Category"), 400) unless category_access?
            error!(I18n.t("denied", acc_to: "Project"), 403)  unless project_access? (@category_member.category.project)

            exist_category
        else
            empty_category
        end
    end

    # => modify with case category_member exist category
    def exist_category
        @old_category_member_empty = @timer.task.category_member
        modify_with_task
    end

    # => modify with case category_member empty category
    def empty_category
        error!(I18n.t("nothing", content: "Update")) unless @timer.task.category_member.category
        @category_member =  @current_member.category_member.create!()
        create_new_task
    end

    def modify_with_task
        params['timer_update']['task_id']? update_exist_task : create_new_task
    end

    def update_exist_task
        task = @category_member.tasks.find_by_id(params['timer_update']['task_id'])
        error!(I18n.t("not_found", title: "Task"), 404) unless task

        update_timer(task)
    end

    def create_new_task
        Task.transaction do
            task = @category_member.tasks.create!(name: params['timer_update']['task_name'])
            update_timer(task)
        end
    end

    def update_timer(task)
        @timer.task_id = task.id
        @timer.start_time = params['timer_update']['start_time']
        @timer.stop_time = params['timer_update']['stop_time']

        @timer.save!

        @old_category_member_empty.destroy! if @old_category_member_empty && !@old_category_member_empty.category
        return_message(I18n.t("success"), TimerSerializer.new(@timer))
    end

    # => true if you be member of project and project have not archived yet
    def project_access?(project)
        !project.is_archived &
            !project.project_members.find_by_member_id(@current_member.id).nil? &
            !project.project_members.find_by_member_id(@current_member.id).is_archived
    end

    # => true if category have not archived yet
    def category_access?
        !@category_member.category.is_archived
    end

    # => true if category_member is current_member, category_member joined in project
    # and meber have yet archived
    def category_member_access?
        (@category_member.project_member.member_id == @current_member.id) &
            !@category_member.project_member.nil? &
            !@category_member.project_member.is_archived
    end

    # => delete empty category or delete task if the timer have onli one task
    def detelte_timer
        if @timer.task.category_member.category
            @timer.task.destroy! unless @timer.task.timers.where.not(id: @timer.id).present?
        else
            @timer.task.category_member.destroy!
        end
    end
end
