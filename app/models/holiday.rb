class Holiday < ApplicationRecord
    belongs_to :company

    validates :name, presence: true, length: { minimum: 1 }
    validates :company_id, presence: true
    validates :begin_date, presence: true
    validates :end_date, presence: true
    validates_uniqueness_of :name, scope: [:company_id, :begin_date]
    validate :begin_date_cannot_be_greater_than_end_date

    validate :conflict_date, on: [:create, :update]

    private
    def begin_date_cannot_be_greater_than_end_date
        errors.add(:begin_date, I18n.t("less_than_end_date")) if begin_date > end_date
    end

    def conflict_date
        conflict_start = conflict_begin_date
        errors.add(:begin_date, I18n.t("already_request")) unless conflict_start.blank?

        conflict_end = conflict_end_date
        errors.add(:end_date, I18n.t("already_request")) unless conflict_end.blank?

        conflict_middle_date if conflict_start.blank? && conflict_end.blank?
    end

    def conflict_begin_date
        Holiday.where('begin_date <= ? and end_date >= ?', begin_date, begin_date)
    end

    def conflict_end_date
        Holiday.where('begin_date <= ? and end_date >= ?', end_date, end_date)
    end

    def conflict_middle_date
        conflict_middle = Holiday.where('((begin_date >= ? and begin_date <= ?) or (end_date >= ? and end_date <= ?))',
            begin_date, end_date, begin_date, end_date)
        errors.add(:begin_date, I18n.t("already_request")) unless conflict_middle.blank?
    end
end
