module ReportApi
    class ReportAdvances < Grape::API
        prefix :api
        version 'v1', using: :accept_version_header

        helpers do
            def prepare_param
                @param_project = JSON.parse(params[:projects].to_s) || nil
                @param_category = JSON.parse(params[:categories].to_s)
                @param_people = JSON.parse(params[:peoples].to_s)
            end

            # => get project for response
            def get_project(project)
                _project = ProjectSerializer.new(project,
                    { begin_date: params['from_date'], end_date: params['to_date']}).to_h
                _project.store('timers', get_timers(project))
                _project.store('categories', project.categories.map { |e|
                    CategoryAdvanceSerializer.new(e,
                        { begin_date: params['from_date'], end_date: params['to_date']}) })
                _project
            end

            # => get timers in each category
            def get_timers(project)
                @timers = []
                categories = @param_category.blank? ? project.categories : project.categories.where(name: @param_category)
                categories.where(is_archived: false).includes(:category_members)
                    .where('is_archived = ?', false).each do |category|
                        member_ables = @param_people.blank? ? project.project_members.where(is_archived: false).select('id') :
                            project.project_members.where(is_archived: false, member_id: @param_people).select('id')
                        checkin_category_member(category, member_ables)
                        push_to_categories(category)
                end
                @timers
            end

            # => get timers in each category_member
            def checkin_category_member(category, member_ables)
                category.category_members.where('project_member_id IN (?)', member_ables)
                    .includes(:tasks).each do |category_member|
                        cate_member_seria = CategoryMemberSerializer.new(category_member,
                            { begin_date: params['from_date'], end_date: params['to_date']})
                        checkin_task(category_member, cate_member_seria)
                end
            end

            # => get timers in each task
            def checkin_task(category_member, cate_member_seria)
                category_member.tasks.each do |task|
                    task_seria = TaskSerializer.new(task).to_h
                    task.timers.where('start_time >= ? and stop_time <= ?', params['from_date'], params['to_date'] )
                        .each do |timer|
                            @timers.push(get_timer(timer, task_seria, cate_member_seria))
                    end
                end
            end

            # => conver to TimerAdvanceSerializer and add TaskSerializer, CategoryMemberSerializer
            def get_timer(timer, task_seria, cate_member_seria)
                timer_seria = TimerAdvanceSerializer.new(timer).to_h
                timer_seria.store('task', task_seria)
                timer_seria.store('category_member', cate_member_seria)
                timer_seria
            end

            # => add category in list category without uniq name.
            def push_to_categories(category)
                @categories.push(category) unless @categories.any?{ |item| item.name == category.name }
            end
        end

        resource :reportadvances do

            params do
                requires :from_date, type: DateTime, desc: 'start date'
                requires :to_date, type: DateTime, desc: 'end date'
                optional :projects, type: String, desc: 'project select'
                optional :categories, type: String, desc: 'category select'
                optional :peoples, type: String, desc: 'member select'
                # all_or_none_of :projects, :categories, :peoples
            end
            get do
                authenticated!
                error!(I18n.t("access_denied"), 403) unless @current_member.admin? || @current_member.pm?
                # prepare param
                prepare_param

                projects = []
                # => constraint all category (uniq name) in all_project
                @categories = []
                # => constraint all member in company
                @company_members = @current_member.company.members.map { |e| MemberUserSerializer.new(e) }

                _projects = @param_project.blank? ? @current_member.company.projects :
                    @current_member.company.projects.where(id: @param_project)
                _projects.map do |project|
                    projects.push(get_project(project))
                end

                return_message(I18n.t("success"), {projects: projects,
                    categories: @categories, company_members: @company_members})
                end
            end
        end
    end
