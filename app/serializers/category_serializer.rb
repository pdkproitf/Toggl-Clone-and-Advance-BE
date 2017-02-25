class CategorySerializer < ActiveModel::Serializer
    attributes :id, :name, :tracked_time, :members
    has_many :members, serializer: MembersSerializer
end
