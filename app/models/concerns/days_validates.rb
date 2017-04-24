module DaysValidates extend ActiveSupport::Concern
    # start date have to less than end date
    def days_valid?(begin_date, begin_field, end_date)
        errors.add("#{begin_field}", I18n.t("less_than_end_date")) if begin_date > end_date
    end

    def conflict_begin_date(id, records, begin_date, begin_field, end_date, end_field, id_field = "id")
        records.where("#{begin_field} <= ? and #{end_field} >= ? and #{id_field} != ?",
            begin_date, begin_date, id)
    end

    def conflict_end_date(id, records, begin_date, begin_field, end_date, end_field, id_field = "id")
        records.where("#{begin_field} <= ? and #{end_field} >= ? and #{id_field} != ?",
            end_date, end_date, id)
    end

    def conflict_middle_date(id, records, begin_date, begin_field, end_date, end_field, id_field = "id")
        conflict_middle = records.where("((#{begin_field} >= ? and #{begin_field} <= ?) or
            (#{end_field} >= ? and #{end_field} <= ?)) and #{id_field} != ?",
            begin_date, end_date, begin_date, end_date, id)
    end

    # => return true if at least one day from begin_date to end_date do not weekend
    def on_weekend?(begin_date, end_date)
        (begin_date.to_i .. end_date.to_i).step(1.day).each do |day|
            return false unless Time.at(day).on_weekend?
        end
        true
    end

    # => return how many days on weekend bettween tow days
    def days_weekends?(begin_date, is_start_half_day, end_date, is_end_half_day)
        days = 0
        (begin_date.to_i .. end_date.to_i).step(1.day).each do |day|
            if Time.at(day).on_weekend?
                days +=   case day
                when begin_date.to_i
                    ((is_start_half_day)? Settings.half_day : Settings.all_day)
                when end_date.to_i
                    ((is_start_half_day)? Settings.half_day : Settings.all_day)
                else
                    1
                end
            end
        end
        days
    end

    # => return diff bettween two days include is_start_half_day and is_end_half_day
    def compute_days(begin_date, is_start_half_day, end_date, is_end_half_day)
        (end_date - begin_date) / 1.day - 1 +
            ((is_start_half_day)? Settings.half_day : Settings.all_day) +
            ((is_end_half_day)? Settings.half_day : Settings.all_day) -
            days_weekends?(begin_date, is_start_half_day, end_date, is_end_half_day)
    end
end
