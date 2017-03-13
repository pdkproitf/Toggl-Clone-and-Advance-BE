class CategorySerializer < ActiveModel::Serializer
  attributes :id, :name, :is_billable, :tracked_time, :members
  attr_reader :members_serialized
  attribute :members, if: :members_serialized

  def initialize(category, options = {})
    super(category)
    @begin_date = options[:begin_date] || nil
    @end_date = options[:end_date] || nil
    @members_serialized = true
    unless options[:members_serialized].nil?
      @members_serialized = options[:members_serialized]
    end
  end

  def tracked_time
    object.tracked_time(@begin_date, @end_date)
  end

  def members
    list = []
    object.category_members
          .where(is_archived_by_category: false)
          .where(is_archived_by_project_member: false)
          .each do |category_member|
      item = {}
      item.merge!(MembersSerializer.new(category_member.project_member.member))
      item[:is_pm] = category_member.project_member.is_pm
      item[:category_member_id] = category_member.id
      item[:tracked_time] = category_member.tracked_time(@begin_date, @end_date)
      list.push(item)
    end
    list
  end
end
