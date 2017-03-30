class TimeOffSerializer < ActiveModel::Serializer
    attributes  :id, :start_date, :end_date, :is_start_half_day, :is_end_half_day,
                :approver_messages, :description, :status, :created_at,
                :updated_at, :sender, :approver
    belongs_to :sender, serializer: MembersSerializer
    belongs_to :approver, serializer: MembersSerializer

end
