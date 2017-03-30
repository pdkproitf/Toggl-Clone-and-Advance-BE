module DaysValidates extend ActiveSupport::Concern
    def days_valid?(begin_date, end_date, field)
        errors.add("#{field}", I18n.t("less_than_end_date")) if begin_date > end_date
    end

    def conflict_date?(records, field, begin_date, end_date, id = 0)
        conflict_start = conflict_begin_date(id, records, field, begin_date)
        errors.add("#{field}", I18n.t("already_request")) unless conflict_start.blank?

        conflict_end = conflict_end_date(id, records, field, begin_date)
        errors.add(:end_date, I18n.t("already_request")) unless conflict_end.blank?

        conflict_middle_date(id, records, field, begin_date) if conflict_start.blank? && conflict_end.blank?
    end

    def conflict_begin_date(id, records, field, begin_date)
        records.where("#{field} <= ? and end_date >= ? and id != ?",
            begin_date, begin_date, id)
    end

    def conflict_end_date(id, records, field, begin_date)
        records.where("#{field} <= ? and end_date >= ? and id != ?",
            end_date, end_date, id)
    end

    def conflict_middle_date(id, records, field, begin_date)
        conflict_middle = records.where("((#{field} >= ? and #{field} <= ?) or
            (end_date >= ? and end_date <= ?)) and id != ?",
            begin_date, end_date, begin_date, end_date, id)
        errors.add(:days, I18n.t("already_request")) unless conflict_middle.blank?
    end
end
