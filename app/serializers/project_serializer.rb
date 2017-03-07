class ProjectSerializer < ActiveModel::Serializer
  attributes :id, :name, :client, :background,
             :is_member_report, :tracked_time, :members
  # has_many :members, serializer: MembersSerializer

  def client
    ClientSerializer.new(object.client)
  end

  def tracked_time
    object.tracked_time
  end

  # def members
  #   object.members.where(project_members: { is_archived: false })
  #   # ActiveModel::Serializer::CollectionSerializer.new(object.members, each_serializer: MembersSerializer)
  # end

  def members
    list = []
    object.project_members.where(is_archived: false)
          .each do |project_member|
      item = {}
      item.merge!(MembersSerializer.new(project_member.member))
      item[:is_pm] = project_member.is_pm
      list.push(item)
    end
    list
  end
end
