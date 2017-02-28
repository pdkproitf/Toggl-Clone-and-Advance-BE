module TimeOffApi
    class TimeOffs < Grape::API
        prefix :api
        version 'v1', using: :accept_version_header

        helpers TimeOffHelper

        resource :timeoffs do
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
