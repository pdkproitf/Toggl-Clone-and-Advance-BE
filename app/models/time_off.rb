class TimeOff < ApplicationRecord
    enum status: [:pending, :approved, :rejected, :archived]

    belongs_to :sender, class_name: 'Member'
    belongs_to :approver, class_name: 'Member'

    validates_presence_of   :start_date, :end_date, :description, :sender_id
    validate :time_valid
    validate :conflit_timeoff, :on => :create
    validate :conflit_timeoff_update, :on => :update

    # before_save :convert_to_beginning_of_day

    private
    def time_valid
        errors.add(:start_date,'have to less than end date') if self.start_date > self.end_date
    end

    def conflit_timeoff_update
        status = [TimeOff.statuses[:rejected]]
        status.push(TimeOff.statuses[:pending]) if self.approver_id_changed?
        conflit_timeoff status, self.id
    end

    def conflit_timeoff status = [TimeOff.statuses[:rejected]], id = 0
        return true if self.status == TimeOff.statuses[:rejected]
        current_member = Member.find_by_id(self.sender_id)
        conflit_start = current_member.off_requests.where('start_date <= ? and end_date >= ? and status NOT IN (?) and id != ?', self.start_date, self.start_date, status, id)
        errors.add(:start_date, 'You already has request off during this time.') if conflit_start.size > 0

        conflit_end = current_member.off_requests.where('(start_date <= ? and end_date >= ? and status NOT IN (?) and id != ?)', self.end_date, self.end_date, status, id)
        errors.add(:end_date, 'You already has request off during this time.') if conflit_end.size > 0
    end

    def convert_to_beginning_of_day
        self.start_date = self.start_date.beginning_of_day
        self.end_date = self.end_date.beginning_of_day
    end
end
