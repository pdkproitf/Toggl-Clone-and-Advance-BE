class TimeOff < ApplicationRecord
    enum status: [:pending, :approved, :rejected, :archived]

    belongs_to :sender, class_name: 'Member'
    belongs_to :approver, class_name: 'Member'

    validates_presence_of :start_date, :end_date, :description, :sender_id
    validate :valid_start_end_days
    validate :conflict_timeoff, on: :create
    validate :conflict_timeoff_update, on: :update

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
        days_valid?(start_date, end_date, 'start_date')
        errors.add(:start_date, I18n.t("over_date")) if start_date < Time.now.beginning_of_day
    end

    def conflict_timeoff_update
        status = [TimeOff.statuses[:rejected]]
        status.push(TimeOff.statuses[:pending]) if approver_id_changed?
        conflict_timeoff(status, id)
    end

    def conflict_timeoff(status = [TimeOff.statuses[:rejected]], id = 0)
        return true if status == TimeOff.statuses[:rejected]

        conflict_date?(sender.off_requests.where.not(status: status), 'start_date', start_date, end_date, id)
    end
end
