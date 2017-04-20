class TimeOff < ApplicationRecord
    enum status: [:pending, :approved, :rejected, :archived]

    belongs_to :sender, class_name: 'Member'
    belongs_to :approver, class_name: 'Member'

    validates_presence_of :start_date, :end_date, :description, :sender_id
    validate :valid_start_end_days
    validate :conflict_timeoff, :conflict_holiday, on: :create
    validate :conflict_timeoff_update, :conflict_holiday_update, on: :update
    validate :constraint_weekend

    after_update :adjust_person_dayoff
    after_destroy :adjust_person_dayoff

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
        errors.add(:start_date, I18n.t("over_date")) if start_date < Time.now.beginning_of_day
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

    def constraint_weekend
        errors.add(:days, I18n.t("timeoff.errors.weekend")) if constraint_weekend?(start_date, end_date)
    end

    def conflict_holiday_update
        conflict_holiday(id)
    end

    def conflict_holiday(id =0)
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

    def adjust_person_dayoff
        if approved?
            diff = compute_days(start_date, is_start_half_day, end_date, is_end_half_day)

            total_day_off = (changed?)? (sender.total_day_off - diff) : (sender.total_day_off + diff)
            day_offed = (changed?)? (sender.day_offed + diff) : (sender.day_offed - diff)

            sender.update_attributes(total_day_off: total_day_off, day_offed: day_offed)
        end
    end
end
