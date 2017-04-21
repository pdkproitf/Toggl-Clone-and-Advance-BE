class CategorySerializer < ActiveModel::Serializer
  attributes :id, :name, :is_billable, :tracked_time, :members
  attr_reader :members_serialized, :perfect_tasks_serialized
  attribute :members, if: :members_serialized

  def initialize(category, options = {})
    super(category)
    @begin_date = options[:begin_date] || nil
    @end_date = options[:end_date] || nil

    @members_serialized = true
    @members_serialized = options[:members_serialized] unless options[:members_serialized].nil? # Can not use "if present?" here

    @perfect_tasks_serialized = false
    @perfect_tasks_serialized = options[:perfect_tasks_serialized] if options[:perfect_tasks_serialized].present?
  end

  def tracked_time
    object.tracked_time(@begin_date, @end_date)
  end

  def members
    list = []
    object.category_members.where(is_archived: false) .each do |category_member|
      item = {}
      item.merge!(MembersSerializer.new(category_member.project_member.member))
      item[:is_pm] = category_member.project_member.is_pm
      item[:category_member_id] = category_member.id
      item[:tracked_time] = category_member.tracked_time(@begin_date, @end_date)

      if perfect_tasks_serialized.present?
        task_options = { each_serializer: TaskSerializer, begin_date: @begin_date, end_date: @end_date }
        item[:tasks] = ActiveModel::Serializer::CollectionSerializer.new(category_member.perfect_tasks, task_options)
      end

      list.push(item)
    end
    list
  end
end
