module TimeOffApi
    class TimeOffs < Grape::API
        prefix :api
        version 'v1', using: :accept_version_header

        helpers TimeOffHelper

        resource :timeoffs do
            desc 'Get all timeoff request of themself'
            get do
                authenticated!
                off_requests = @current_member.off_requests.map { |e|  TimeOffSerializer.new(e)}
                pending_requests = []
                pending_requests = TimeOff.where("created_at > (?)" ,Date.today.beginning_of_year).map { |e|  TimeOffSerializer.new(e)} if @current_member.admin? || @current_member.pm?
                return_message 'Success', {off_requests: off_requests, pending_requests: pending_requests}
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
        end
    end
end
