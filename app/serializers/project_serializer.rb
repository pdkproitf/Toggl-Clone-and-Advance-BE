class ProjectSerializer < ActiveModel::Serializer
    def method_name
        object.name
    end
    attributes :id, :background, :method_name
    belongs_to :client
end
