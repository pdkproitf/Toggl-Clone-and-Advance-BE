module HolidayHelper
    include Datetimes::Week
    # Get all holidays in week of a date -> create @Linh
    def holidays_in_week(company, week_start_date)
        holidays = company.holidays
        holidays_in_week = []
        (week_start_date..week_start_date + 6).each do |date_in_week|
            holidays.each do |holiday|
                if date_in_week >= holiday.begin_date && date_in_week <= holiday.end_date
                    holidays_in_week.push(date_in_week)
                    break
                end
            end
        end
        holidays_in_week
    end

    # => create pdkpro
    def create_params
        ActionController::Parameters.new(params).require(:holiday)
            .permit(:name, :begin_date, :end_date, :is_repeat)
    end
end
