class TestsSerializer < ActiveModel::Serializer
    attributes :id
    belongs_to :client, serializer: ClientSerializer, key: :cube
    has_many :categories, serializer: CategorySerializer
end
