module DaysValidates extend ActiveSupport::Concern
    # start date have to less than end date
    def days_valid?(begin_date, begin_field, end_date)
        errors.add("#{begin_field}", I18n.t("less_than_end_date")) if begin_date > end_date
    end

    def conflict_begin_date(id, records, begin_date, begin_field, end_date, end_field)
        records.where("#{begin_field} <= ? and #{end_field} >= ? and id != ?",
            begin_date, begin_date, id)
    end

    def conflict_end_date(id, records, begin_date, begin_field, end_date, end_field)
        records.where("#{begin_field} <= ? and #{end_field} >= ? and id != ?",
            end_date, end_date, id)
    end

    def conflict_middle_date(id, records, begin_date, begin_field, end_date, end_field)
        conflict_middle = records.where("((#{begin_field} >= ? and #{begin_field} <= ?) or
            (#{end_field} >= ? and #{end_field} <= ?)) and id != ?",
            begin_date, end_date, begin_date, end_date, id)
    end

    def constraint_weekend?(begin_date, end_date)
        (begin_date.to_i .. end_date.to_i).step(1.day).each do |day|
            if Time.at(day).on_weekend?
                return true
            end
        end
        false;
    end
end
