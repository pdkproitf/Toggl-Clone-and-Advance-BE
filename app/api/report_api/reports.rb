module ReportApi
  class Reports < Grape::API
    prefix :api
    version 'v1', using: :accept_version_header

    helpers do
      def validate_date(begin_date, end_date)
        if begin_date > end_date
          error!(I18n.t('begin_date_not_greater_than_end_day'), 400)
        end
        error!(I18n.t('day_limit'), 400) if (end_date - begin_date).to_i > 366
      end
    end

    resource :reports do
      # => /api/v1/reports/
      desc 'Report by time'
      params do
        requires :begin_date, type: Date, desc: 'Begin date'
        requires :end_date, type: Date, desc: 'End date'
      end
      get 'time' do
        authenticated!
        validate_date(params[:begin_date], params[:end_date])
        report = Report.new(@current_member,
                            params[:begin_date],
                            params[:end_date])
        { data: report.report_by_time }
      end

      desc 'Report by projects'
      params do
        requires :begin_date, type: Date, desc: 'Begin date'
        requires :end_date, type: Date, desc: 'End date'
      end
      get 'project' do
        authenticated!
        validate_date(params[:begin_date], params[:end_date])
        projects = @current_member.company.projects.where(is_archived: false)
        # If member is not pm of any project then access denied
        if @current_member.member? &&
           @current_member.project_members
                          .where(project_id: projects.ids,
                                 is_pm: true, is_archived: false)
                          .empty?
          return error!(I18n.t('access_denied'), 403)
        end
        report = Report.new(@current_member,
                            params[:begin_date], params[:end_date])
        { data: report.report_by_project }
      end

      desc 'Report by member'
      params do
        requires :begin_date, type: Date, desc: 'Begin date'
        requires :end_date, type: Date, desc: 'End date'
        requires :member_id, type: Integer, desc: 'Member ID'
      end
      get 'member' do
        authenticated!
        @current_member = Member.find(4)
        validate_date(params[:begin_date], params[:end_date])
        member = @current_member.company.members.find(params[:member_id])
        # Only Admin can run report of himself
        if (member.admin? && !@current_member.admin?) ||
           # Staff cannot run report of super PM
           (member.pm? && @current_member.member?)
          return error!(I18n.t('access_denied'), 403)
        end

        if member.member? && member.id != @current_member.id
          # IDs of projects that current_member is pm
          project_ids = @current_member.pm_projects
                                       .where(is_archived: false)
                                       .ids
          member_joined_project = member.project_members
                                        .where(project_id: project_ids,
                                               is_archived: false)
          if member_joined_project.empty?
            return error!(I18n.t('access_denied'), 403)
          end
        end

        report = Report.new(@current_member, params[:begin_date],
                            params[:end_date], member: member)
        { data: report.report_by_member }
      end
    end
  end
end
