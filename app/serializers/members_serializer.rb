class MembersSerializer < ActiveModel::Serializer
    attributes :member
    belongs_to :company, serializer: CompaniesSerializer
    belongs_to :user, serializer: UserSerializer
    belongs_to :role, serializer: RolesSerializer

    def member
        {
            "id": object.id,
            "furlough_total": object.furlough_total
        }
    end
end
