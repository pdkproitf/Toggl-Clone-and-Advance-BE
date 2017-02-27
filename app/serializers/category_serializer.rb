class CategorySerializer < ActiveModel::Serializer
    attributes :id, :name, :tracked_time
    has_many :members, serializer: MembersSerializer
end
