class ProjectSerializer < ActiveModel::Serializer
    attributes :id, :name, :background, :client, :tracked_time, :members

    def client
        ClientSerializer.new(object.client)
    end

    def tracked_time
        object.get_tracked_time
    end

    # def members
    #     # object.members
    #     # ActiveModel::Serializer::CollectionSerializer.new(object.members, each_serializer: MembersSerializer)
    #     # ActiveModel::ArraySerializer.new(object.members).as_json
    # end

    has_many :members, serializer: MembersSerializer
end
