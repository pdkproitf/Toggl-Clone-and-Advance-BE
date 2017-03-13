module TimeOffApi
    class TimeOffs < Grape::API
        prefix :api
        version 'v1', using: :accept_version_header

        helpers TimeOffHelper

        resource :timeoffs do
            desc 'Get all timeoff request'
            params do
                optional :from_date, type: DateTime, desc: 'start date'
                optional :to_date, type: DateTime, desc: 'end date'
                optional :status, type: String, desc: 'status request'
                all_or_none_of :from_date, :to_date, :status
            end
            get do
                authenticated!
                return return_message 'Access Denied' unless (@current_member.admin? || @current_member.pm?)
                return get_phase if params['from_date']
                return get_all
            end

            desc 'Get timeoff request of themself '
            get ':id' do
                authenticated!
                @timeoff = TimeOff.find_by_id(params['id'])
                return return_message "Not Found timeoff with id #{params['id']}" unless @timeoff
                return return_message "Access Denied timeoff id #{params['id']} with member #{current_member.user.email}" unless @timeoff.sender.id == @current_member.id
                return_message 'Success', @timeoff
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
                authenticated!
                timeoff = create_timeoff
                send_email_to_boss timeoff
                return_message 'Your time off created. The email will be send to your bosses after few minutes'
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
                authenticated!
                @timeoff = TimeOff.find_by_id(params['id'])
                return return_message "Not Found timeoff with id #{params['id']}" unless @timeoff

                if params['timeoff']
                    return return_message "Access Denied! You can't modify this Request" unless @timeoff.sender_id == @current_member.id
                    return return_message "Not Allow!  Your request was answered. If you want to change, you can delete this request and create new request" unless @timeoff.pending?
                    update_timeoff
                    send_email_to_boss @timeoff
                else
                    return return_message "Access Denied! You have not enough able to answer this request" unless able_to_answer_request?
                    answer_timeoff
                    send_answer_to_person_relative
                end
                return_message 'Success', @timeoff
            end


            desc 'Delete timeoff request'
            delete ':id' do
                authenticated!
                status 200
                @timeoff = TimeOff.find_by_id(params['id'])
                return return_message "Error Not Found timeoff with id #{params['id']}" unless @timeoff
                (@current_member.admin? && @current_member.id != @timeoff.sender_id)? admin_delete : sender_delete
            end
        end
    end
end
