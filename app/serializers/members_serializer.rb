class MembersSerializer < ActiveModel::Serializer
    attributes :id, :furlough_total
    belongs_to :company, serializer: CompaniesSerializer
    belongs_to :user, serializer: UserSerializer
    belongs_to :role, serializer: RolesSerializer
end
