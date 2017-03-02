class TimeOffSerializer < ActiveModel::Serializer
    attributes  :id, :start_date, :end_date, :is_start_half_day, :is_end_half_day,
                :description, :status, :created_at, :updated_at, :sender, :approver

    def sender
        MembersSerializer.new(object.sender)
    end

    def approver
        MembersSerializer.new(object.approver)
    end
end
