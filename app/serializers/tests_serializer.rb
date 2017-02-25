class TestsSerializer < ActiveModel::Serializer
    attributes :method_name
    belongs_to :client, serializer: ClientSerializer
    has_many :categories, serializer: CategorySerializer

    def method_name
        {"id": object.id}
    end
end
