class Holiday < ApplicationRecord
    belongs_to :company

    validates :name, length: { minimum: 2 }
    validates_presence_of :begin_date, :end_date, :company_id
    validate :days_valid
    validate :conflict_date, on: [:create, :update]

    private
    # begin_date_cannot_be_greater_than_end_date
    def days_valid
        errors.add(:begin_date, I18n.t("less_than_end_date")) if begin_date > end_date
    end

    def conflict_date(id = nil)
        conflict_start = conflict_begin_date(id)
        errors.add(:begin_date, I18n.t("already_request")) unless conflict_start.blank?

        conflict_end = conflict_end_date(id)
        errors.add(:end_date, I18n.t("already_request")) unless conflict_end.blank?

        conflict_middle_date(id) if conflict_start.blank? && conflict_end.blank?
    end

    def conflict_date_update
        conflict_date(id)
    end

    def conflict_begin_date(id)
        Holiday.where('begin_date <= ? and end_date >= ? and company_id = ? and id != ?',
            begin_date, begin_date, company_id, id)
    end

    def conflict_end_date(id)
        Holiday.where('begin_date <= ? and end_date >= ? and company_id = ? and id != ?',
            end_date, end_date, company_id, id)
    end

    def conflict_middle_date(id)
        conflict_middle = Holiday.where('((begin_date >= ? and begin_date <= ?) or
            (end_date >= ? and end_date <= ?)) and company_id = ? and id != ?',
            begin_date, end_date, begin_date, end_date, company_id, id)
        errors.add(:begin_date, I18n.t("already_request")) unless conflict_middle.blank?
    end
end
