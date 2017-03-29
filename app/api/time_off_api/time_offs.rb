module TimeOffApi
    class TimeOffs < Grape::API
        prefix :api
        version 'v1', using: :accept_version_header

        helpers TimeOffHelper

        resource :timeoffs do
            before do
                authenticated!
            end

            desc 'Get all timeoff request'
            params do
                optional :from_date, type: DateTime, desc: 'start date'
                optional :to_date, type: DateTime, desc: 'end date'
                optional :status, type: String, desc: 'status request'
                all_or_none_of :from_date, :to_date, :status
            end
            get do
                return get_phase if params['from_date'] #get request folow phase
                return get_all  # get all request
            end

            desc 'Get number timeoff of person'
            params do
                optional :id, type: Integer, desc: 'timeoff id'
                all_or_none_of :id
            end
            get '/num-of-timeoff' do
                if params['id']
                    timeoff = TimeOff.find_by_id(params['id'])
                    error!(I18n.t('not_found', title: 'Timeoff'), 404) unless timeoff
                    error!(I18n.t('access_denied'), 403) unless @current_member.manager?
                    @current_member = timeoff.sender
                end
                offed_date = @current_member
                    .off_requests
                    .where('created_at >= (?) and status = (?)',
                        Date.today.beginning_of_year, TimeOff.statuses[:approved])
                return_message(I18n.t("success"), offed_approver(offed_date))
            end

            desc 'Get a timeoff request of themself '
            get ':id' do
                @timeoff = TimeOff.find_by_id(params['id'])
                error!(I18n.t("not_found", title: "timeoff"), 404) unless @timeoff
                error!(I18n.t("access_denied"), 403) unless (@timeoff.sender_id == @current_member.id) || able_answer_request?
                return_message(I18n.t("success"), @timeoff)
            end

            desc 'Create time off'
            params do
                requires :timeoff, type: Hash do
                    requires :start_date, type: DateTime, desc: 'the day begin off'
                    requires :end_date, type: DateTime, desc: 'The last day off'
                    requires :is_start_half_day, type: Boolean, desc: 'off half day'
                    requires :is_end_half_day, type: Boolean, desc: 'off half day'
                    requires :description, type: String, desc: 'The reason day off'
                end
            end

            post do
                inform_request(create_timeoff)
                return_message I18n.t("timeoff.created")
            end

            desc 'Update time off'
            params do
                optional :timeoff, type: Hash do
                    requires :start_date, type: DateTime, desc: 'the day begin off'
                    requires :end_date, type: DateTime, desc: 'The last day off'
                    requires :is_start_half_day, type: Boolean, desc: 'off half day'
                    requires :is_end_half_day, type: Boolean, desc: 'off half day'
                    requires :description, type: String, desc: 'The reason day off'
                end

                optional :answer_timeoff_request, type: Hash do
                    requires :status, type: String, desc: 'Status: approved, rejected, archived'
                    requires :approver_messages, type: String, desc: 'Messages to who create request'
                end

                exactly_one_of :timeoff, :answer_timeoff_request
            end

            put ':id' do
                @timeoff = TimeOff.find_by_id(params['id'])
                error!(I18n.t("not_found", title: "timeoff"), 404) unless @timeoff

                if params['timeoff']
                    error!(I18n.t("access_denied", 404)) unless (@timeoff.sender_id == @current_member.id) || able_answer_request?
                    error!(I18n.t("timeoff.request_answed"), 400) unless @timeoff.pending?
                    update_timeoff
                else
                    error!(I18n.t("access_denied"), 403) unless able_answer_request?
                    answer_timeoff
                end
            end

            desc 'Delete timeoff request'
            delete ':id' do
                status 200
                @timeoff = TimeOff.find_by_id(params['id'])
                error!(I18n.t("not_found", title: "Timeoff"), 404) unless @timeoff
                (@current_member.admin? && @current_member.id != @timeoff.sender_id)? admin_delete : sender_delete
            end
        end
    end
end
