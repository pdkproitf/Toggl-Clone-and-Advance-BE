class RoleSerializer < ActiveModel::Serializer
    attributes :id, :name
    # has_many :users, through: :project_user_roles
end
