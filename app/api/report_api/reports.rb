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
        validate_date(params[:begin_date], params[:end_date])
        project = @current_member.company.projects.find(params[:project_id])
        project_member = @current_member.project_members
                                        .find_by(project_id: project.id)
        if @current_member.member?
          if project_member.nil?
            return error!(I18n.t('not_added_to_project'), 403)
          end
          if project_member.is_pm == false
            return error!(I18n.t('access_denied'), 403)
          end
        end

        report = Report.new(@current_member, params[:begin_date],
                            params[:end_date], project: project)
        { data: report.report_by_time }
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
        @current_member = Member.find(3)
        validate_date(params[:begin_date], params[:end_date])
        project = @current_member.company.projects.find(params[:project_id])
        member = @current_member.company.members.find(params[:member_id])
        # Only Admin can run report of himself
        if member.admin? && !@current_member.admin?
          return error!(I18n.t('access_denied'), 403)
        end
        # Staff cannot run report of super PM
        if member.pm? && @current_member.member?
          return error!(I18n.t('access_denied'), 403)
        end

        if member.member? && @current_member.member? &&
           member.id != @current_member.id
          return error!(I18n.t('access_denied'), 403)
        end

        project_member = @current_member.project_members
                                        .find_by(project_id: project.id)
        if @current_member.member? && project_member.nil?
          return error!(I18n.t('not_added_to_project'), 403)
        end

        # report = Report.new(@current_member,
        #                     params[:begin_date], params[:end_date],
        #                     project: project, member: member)
        # { data: report.report_by_member }
      end
    end
  end
end
