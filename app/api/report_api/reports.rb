module ReportApi
  class Reports < Grape::API
    prefix :api
    version 'v1', using: :accept_version_header

    helpers do
      def validate_date(begin_date, end_date)
        if begin_date > end_date
          error!(I18n.t('begin_date_not_greater_than_end_day'), 400)
        end
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
        # Every member get permission to report
        authenticated!
        # Validate begin and end date
        validate_date(params[:begin_date], params[:end_date])
        { data: Report.new(@current_member,
                           params[:begin_date],
                           params[:end_date])
                      .report_by_time }
      end

      desc 'Report by project'
      params do
        requires :begin_date, type: Date, desc: 'Begin date'
        requires :end_date, type: Date, desc: 'End date'
        requires :project_id, type: Integer, desc: 'Project ID'
      end
      get 'project' do
        authenticated!
        # Who get permission to report
        project = @current_member.company.projects.find(params[:project_id])
        project_member = @current_member.project_members
                                        .find_by(project_id: project.id)
        if project_member.nil?
          return error!(I18n.t('not_added_to_project'), 403)
        end
        if @current_member.member? && project_member.is_pm = false
          return error!(I18n.t('access_denied'), 403)
        end

        validate_date(params[:begin_date], params[:end_date])

        Report.new(@current_member, params[:begin_date], params[:end_date],
                   project: project).report_by_project
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
        return params
        report = Report.new(@current_member, params[:begin_date], params[:end_date],
                            project_id: params[:project_id],
                            member_id: params[:member_id])
        report.report_by_member
      end
    end
  end
end
