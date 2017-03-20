class TimeOff < ApplicationRecord
    enum status: [:pending, :approved, :rejected, :archived]

    belongs_to :sender, class_name: 'Member'
    belongs_to :approver, class_name: 'Member'

    validates_presence_of   :start_date, :end_date, :description, :sender_id
    validate :time_valid
    validate :conflict_timeoff, on: :create
    validate :conflict_timeoff_update, on: :update

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
        current_member = sender
        conflict_start = current_member
            .off_requests
            .where('start_date <= ? and end_date >= ? and status NOT IN (?) and id != ?',
                self.start_date, self.start_date, status, id)
        errors.add(:start_date, I18n.t("timeoff.errors.already_request")) if conflict_start.size > 0

        conflict_end = current_member
            .off_requests
            .where('(start_date <= ? and end_date >= ? and status NOT IN (?) and id != ?)',
                self.end_date, self.end_date, status, id)
        errors.add(:end_date, I18n.t("timeoff.errors.already_request")) if conflict_end.size > 0
    end

    def convert_to_beginning_of_day
        self.start_date = self.start_date.beginning_of_day
        self.end_date = self.end_date.beginning_of_day
    end
end
