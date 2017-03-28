class MemberUserSerializer < ActiveModel::Serializer
    attributes :id
    belongs_to :user, serializer: UserSerializer
    belongs_to :role, serializer: RolesSerializer
    has_many   :jobs
end
