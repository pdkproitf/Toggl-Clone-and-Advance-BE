class InviteSerializer < ActiveModel::Serializer
    attributes :id, :email, :is_accepted, :updated_at, :expiry
    belongs_to :sender, serializer: MemberUserSerializer
    belongs_to :recipient, serializer: MemberUserSerializer
end
