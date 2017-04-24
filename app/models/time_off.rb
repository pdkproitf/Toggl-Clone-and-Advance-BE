class TimeOff < ApplicationRecord
    enum status: [:pending, :approved, :rejected, :archived]

    belongs_to :sender, class_name: 'Member'
    belongs_to :approver, class_name: 'Member'

    validates_presence_of :start_date, :end_date, :description, :sender_id
    validate :valid_start_end_days
    validate :conflict_timeoff, :conflict_holiday, on: :create
    validate :conflict_timeoff_update, :conflict_holiday_update, on: :update
    validate :is_weekends

    after_update :add_person_dayoffed
    before_update :sub_person_dayoffed
    before_destroy :sub_person_dayoffed

    def send_email send_mail_to, current_member = nil
        send_mail_to.each do |member|
            TimeOffMailer.timeoff_announce(self, member.user.email, current_member)
                .deliver_later(wait: Settings.send_later.seconds)
        end
    end

    private
    include DaysValidates

    # begin_date_cannot_be_greater_than_end_date
    def valid_start_end_days
        days_valid?(start_date, 'start_date', end_date)
    end

    def conflict_timeoff_update
        status = [TimeOff.statuses[:rejected]]
        status.push(TimeOff.statuses[:pending]) if approver_id_changed?
        conflict_timeoff(status, id)
    end

    def conflict_timeoff(status = [TimeOff.statuses[:rejected]], id = 0)
        return true if status == TimeOff.statuses[:rejected]
        records = sender.off_requests.where.not(status: status)

        conflict_start = conflict_begin_date(id, records, start_date, 'start_date', end_date, 'end_date')
        errors.add("start_date", I18n.t("already_request")) unless conflict_start.blank?

        conflict_end = conflict_end_date(id, records, start_date, 'start_date', end_date, 'end_date')
        errors.add("end_date", I18n.t("already_request")) unless conflict_end.blank?

        if conflict_start.blank? && conflict_end.blank?
            conflict_middle = conflict_middle_date(id, records, start_date, 'start_date', end_date, 'end_date')
            errors.add(:days, I18n.t("already_request")) unless conflict_middle.blank?
        end
    end

    def is_weekends
        errors.add(:days, I18n.t("timeoff.errors.weekend")) if on_weekend?(start_date, end_date)
    end

    def conflict_holiday_update
        conflict_holiday(id)
    end

    def conflict_holiday(id = 0)
        records = sender.company.holidays
        conflict_start = conflict_begin_date(id, records, start_date, 'begin_date', end_date, 'end_date')
        errors.add("start_date", I18n.t('timeoff.errors.holiday')) unless conflict_start.blank?

        conflict_end = conflict_end_date(id, records, start_date, 'begin_date', end_date, 'end_date')
        errors.add("end_date", I18n.t("timeoff.errors.holiday")) unless conflict_end.blank?

        if conflict_start.blank? && conflict_end.blank?
            conflict_middle = conflict_middle_date(id, records, start_date, 'begin_date', end_date, 'end_date')
            errors.add(:days, I18n.t("timeoff.errors.holiday")) unless conflict_middle.blank?
        end
    end

    def sub_person_dayoffed
        if destroyed?
            adjust_person_dayoff(false, start_date, is_start_half_day,
                end_date, is_end_half_day) if approved?
        else
            adjust_person_dayoff(false, start_date_was, is_start_half_day_was,
                end_date_was, is_end_half_day_was) if status_was == "approved"
        end
    end

    def add_person_dayoffed
        adjust_person_dayoff(true, start_date, is_start_half_day,
            end_date, is_end_half_day) if approved?
    end

    def adjust_person_dayoff(is_plus_dayoff, start_date, is_start_half_day, end_date, is_end_half_day)
        diff = compute_days(start_date, is_start_half_day, end_date, is_end_half_day)
        total_day_off = (is_plus_dayoff)? (sender.total_day_off - diff) : (sender.total_day_off + diff)
        day_offed = (is_plus_dayoff)? (sender.day_offed + diff) : (sender.day_offed - diff)

        sender.update_attributes(total_day_off: total_day_off, day_offed: day_offed)
    end
end
