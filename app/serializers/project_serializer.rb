class ProjectSerializer < ActiveModel::Serializer
  attributes :id, :name, :client, :background,
             :is_member_report, :tracked_time
  attr_reader :is_members_serialized
  attribute :members, if: :is_members_serialized
  # has_many :members, serializer: MembersSerializer

  def initialize(project, options = {})
    super(project)
    @begin_date = options[:begin_date] || nil
    @end_date = options[:end_date] || nil
    @is_members_serialized = true
    unless options[:is_members_serialized].nil?
      @is_members_serialized = options[:is_members_serialized]
    end
  end

  def client
    ClientSerializer.new(object.client)
  end

  def tracked_time
    object.tracked_time(@begin_date, @end_date)
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
