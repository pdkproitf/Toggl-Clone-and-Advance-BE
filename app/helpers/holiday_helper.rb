module HolidayHelper
  include Datetimes::Week
  # Get all holidays in week of a date
  def holidays_in_week(week_date, week_first_day)
    week_start_date = week_start_date(week_date, week_first_day)
    @reporter.company.holidays
    holidays = @reporter.company.holidays
    holidays_in_week_of_date = []
    (week_start_date..week_start_date + 6).each do |date_in_week|
      holidays.each do |holiday|
        if date_in_week >= holiday.begin_date &&
           date_in_week <= holiday.end_date
          holidays_in_week_of_date.push(date_in_week)
          break
        end
      end
    end
    holidays_in_week_of_date
  end
end
