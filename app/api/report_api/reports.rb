module ReportApi
  class Reports < Grape::API
    prefix :api
    version 'v1', using: :accept_version_header

    helpers do
      def check_begin_end_date_correct(begin_date, end_date)
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
        # Who get permission to report
        if !@current_member.admin? && @current_member.pm?
          return error!(I18n.t('access_denied'), 400)
        end
        check_begin_end_date_correct(params[:begin_date], params[:end_date])
        Report.new(@current_member, params[:begin_date], params[:end_date])
              .report_by_time
      end

      desc 'Report by project'
      params do
        requires :begin_date, type: Date, desc: 'Begin date'
        requires :end_date, type: Date, desc: 'End date'
        requires :project_id, type: Integer, desc: 'Project ID'
      end
      get 'project' do
        authenticated!
        return Report.new(@current_member, params[:begin_date],
                          params[:end_date]).overtime?(params[:end_date])
        # Who get permission to report
        if !@current_member.admin? && @current_member.pm? &&
           !@current_member.project_members
                           .exists?(project_id: params[:project_id])
          return error!(I18n.t('access_denied'), 400)
        end
        check_begin_end_date_correct(params[:begin_date], params[:end_date])
        Report.new(@current_member, params[:begin_date], params[:end_date],
                   project_id: params[:project_id]).report_by_project
      end

      desc 'Report by member'
      # params do
      #   requires :report, type: Hash do
      #     requires :begin_date, type: Date, desc: 'Begin date'
      #     requires :end_date, type: Date, desc: 'End date'
      #     optional :project_id, type: Date, desc: 'Project ID'
      #     optional :member_id, type: Date, desc: 'Member ID'
      #   end
      # end
      params do
        requires :begin_date, type: Date, desc: 'Begin date'
        requires :end_date, type: Date, desc: 'End date'
      end
      get 'member' do
        authenticated!
        # Who get permission to report
        return error!(I18n.t('access_denied'), 400) unless @current_member.admin?
        @current_member.company
      end
    end
  end
end
