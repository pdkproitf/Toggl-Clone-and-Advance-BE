module ReportApi
  class Reports < Grape::API
    prefix :api
    version 'v1', using: :accept_version_header

    helpers do
      def validate_date(begin_date, end_date)
        if begin_date > end_date
          error!(I18n.t('begin_date_not_greater_than_end_day'), 400)
        end
        error!(I18n.t('day_limit'), 400) if (end_date - begin_date).to_i > 100
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

      desc 'Report by project'
      params do
        requires :begin_date, type: Date, desc: 'Begin date'
        requires :end_date, type: Date, desc: 'End date'
        requires :project_id, type: Integer, desc: 'Project ID'
      end
      get 'project' do
        authenticated!
        @current_member = Member.find(3)
        validate_date(params[:begin_date], params[:end_date])
        project = @current_member.company.projects.find(params[:project_id])
        if project.is_archived == true
          return error!(I18n.t('project_archived'), 404)
        end
        if @current_member.member? && !@current_member.pm_of_project?(project)
          return error!(I18n.t('access_denied'), 403)
        end
        report = Report.new(@current_member, params[:begin_date],
                            params[:end_date], project: project)
        { data: report.report_by_project }
      end

      desc 'Report by member'
      params do
        requires :begin_date, type: Date, desc: 'Begin date'
        requires :end_date, type: Date, desc: 'End date'
        requires :project_id, type: Integer, desc: 'Project ID'
        requires :member_id, type: Integer, desc: 'Member ID'
      end
      get 'member' do
        authenticated!
        validate_date(params[:begin_date], params[:end_date])
        project = @current_member.company.projects.find(params[:project_id])
        member = @current_member.company.members.find(params[:member_id])
        # Only Admin can run report of himself
        if (member.admin? && !@current_member.admin?) ||
           # Staff cannot run report of super PM
           (member.pm? && @current_member.member?) ||
           # Staff only run report of himself
           (member.member? && @current_member.member? &&
              member.id != @current_member.id)
          return error!(I18n.t('access_denied'), 403)
        end

        if member.member? && !member.joined_project?(project)
          return error!(I18n.t('not_added_to_project'), 403)
        end

        report = Report.new(@current_member,
                            params[:begin_date], params[:end_date],
                            project: project, member: member)
        { data: report.report_by_member }
      end
    end
  end
end
