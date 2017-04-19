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
                return_message(I18n.t('success'),
                    @current_member.company.holidays.map { |e| HolidaySerializer.new(e) })
            end

            desc 'Create new holiday'
            params do
                requires :holiday, type: Hash do
                    requires :name, type: String, desc: 'Holiday name'
                    requires :begin_date, type: DateTime, desc: 'Begin day'
                    requires :end_date, type: DateTime, desc: 'End day'
                    requires :kind, type: String, desc: 'type of holiday'
                end
            end
            post do
                holiday = @current_member.company.holidays.create!(create_params)
                return_message(I18n.t('success'), HolidaySerializer.new(holiday))
            end

            desc 'Get a holiday'
            get ':id' do
                holiday = @current_member.company.holidays.find(params[:id])
                return_message(I18n.t('success'), HolidaySerializer.new(holiday))
            end

            desc 'Edit holiday'
            params do
                requires :holiday, type: Hash do
                    requires :name, type: String, desc: 'Holiday name'
                    requires :begin_date, type: DateTime, desc: 'Begin day'
                    requires :end_date, type: DateTime, desc: 'End day'
                    requires :kind, type: String, desc: 'type of holiday'
                end
            end
            put ':id' do
                holiday = @current_member.company.holidays.find(params[:id])
                holiday.update_attributes!(create_params)
                return_message(I18n.t('success'), HolidaySerializer.new(holiday))
            end

            desc 'Destroy holiday'
            delete ':id' do
                holiday = @current_member.company.holidays.find(params[:id])
                holiday.destroy!
                status 200
                return_message(I18n.t('success'))
            end
        end
    end
end
