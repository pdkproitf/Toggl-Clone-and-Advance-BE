class ProjectSerializer < ActiveModel::Serializer
  attributes :id, :name, :client, :background,
             :is_member_report, :tracked_time
  attribute :members, if: :is_members_serialized
  # has_many :members, serializer: MembersSerializer

  def initialize(project, begin_date = nil, end_date = nil, is_members_serialized = true)
    super(project)
    @begin_date = begin_date
    @end_date = end_date
    @is_members_serialized = is_members_serialized
  end

  def client
    ClientSerializer.new(object.client)
  end

  def tracked_time
    object.tracked_time(@begin_date, @end_date)
  end

  attr_reader :is_members_serialized

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
