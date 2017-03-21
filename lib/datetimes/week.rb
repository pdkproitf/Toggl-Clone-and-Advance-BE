# /lib/date_times/week.rb
module Datetimes
  module Week
    def week_start_date(week_day, week_first_day)
      day_diff = week_day.wday - week_first_day
      day_diff += 7 if day_diff < 0
      week_day - day_diff
    end
  end
end
