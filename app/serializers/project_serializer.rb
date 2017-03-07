class ProjectSerializer < ActiveModel::Serializer
  attributes :id, :name, :background, :client, :tracked_time, :members
  has_many :members, serializer: MembersSerializer

  def client
    ClientSerializer.new(object.client)
  end

  def tracked_time
    object.get_tracked_time
  end

  def members
    object.members.where(project_members: { is_archived: false })
    # ActiveModel::Serializer::CollectionSerializer.new(object.members, each_serializer: MembersSerializer)
  end
end
