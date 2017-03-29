module HolidayApi
    class Holidays < Grape::API
        prefix :api
        version 'v1', using: :accept_version_header
        #
        helpers HolidayHelper

        resource :holidays do

            before do
                authenticated!
                error!(I18n.t('access_denied'), 403) unless @current_member.admin?
            end

            desc 'Get all holidays'
            get do
                @current_member.company.holidays
            end

            desc 'Create new holiday'
            params do
                requires :holiday, type: Hash do
                    requires :name, type: String, desc: 'Holiday name'
                    requires :begin_date, type: Date, desc: 'Begin day'
                    requires :end_date, type: Date, desc: 'End day'
                end
            end
            post do
                holiday = @current_member.company.holidays.create!(create_params)
                return_message(I18n.t('success'), HolidaySerializer.new(holiday))
            end

            desc 'Get a holiday'
            get ':id' do
                holiday = Holiday.find(params[:id])
                return_message(I18n.t('success'), HolidaySerializer.new(holiday))
            end
        end
    end
end
