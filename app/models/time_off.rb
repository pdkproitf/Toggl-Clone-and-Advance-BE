class TimeOff < ApplicationRecord
    enum status: [:pending, :approved, :rejected, :archived]

    belongs_to :sender, -> {where(is_archived: false)}, class_name: 'Member'
    belongs_to :approver, class_name: 'Member'

    validates_presence_of   :start_date, :end_date, :description, :sender_id
    validate :time_valid
    validate :conflict_timeoff, on: :create
    validate :conflict_timeoff_update, on: :update

    # default_scope -> { where("sender_id NOT NULL") }
    # before_save :convert_to_beginning_of_day

    def send_email send_mail_to, current_member = nil
        send_mail_to.each do |member|
            TimeOffMailer.timeoff_announce(self, member.user.email, current_member)
            .deliver_later(wait: Settings.send_later.seconds)
        end
    end

    private
    def time_valid
        errors.add(:start_date, I18n.t("timeoff.errors.start_date")) if start_date > end_date
    end

    def conflict_timeoff_update
        status = [TimeOff.statuses[:rejected]]
        status.push(TimeOff.statuses[:pending]) if approver_id_changed?
        conflict_timeoff status, id
    end

    def conflict_timeoff status = [TimeOff.statuses[:rejected]], id = 0
        return true if status == TimeOff.statuses[:rejected]

        conflict_start = sender
            .off_requests
            .where('start_date <= ? and end_date >= ? and status NOT IN (?) and id != ?',
                start_date, start_date, status, id)
        errors.add(:start_date, I18n.t("timeoff.errors.already_request")) unless conflict_start.blank?

        conflict_end = sender
            .off_requests
            .where('(start_date <= ? and end_date >= ? and status NOT IN (?) and id != ?)',
                end_date, end_date, status, id)
        errors.add(:end_date, I18n.t("timeoff.errors.already_request")) unless conflict_end.blank?

        if(conflict_start.blank? && conflict_end.blank?)
            conflict_middle = sender
                .off_requests
                .where('(((start_date >= ? and start_date <= ?) or (end_date >= ? and end_date <= ?)) and status NOT IN (?) and id != ?)',
                    start_date, end_date, start_date, end_date, status, id)
            errors.add(:start_date, I18n.t("timeoff.errors.already_request")) unless conflict_middle.blank?
        end
    end

    def convert_to_beginning_of_day
        start_date = start_date.beginning_of_day
        end_date = end_date.beginning_of_day
    end
end
