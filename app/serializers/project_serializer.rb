class ProjectSerializer < ActiveModel::Serializer
  attributes :id, :name, :client, :background, :updated_at,
             :is_member_report, :tracked_time
  attr_reader :chart_serialized, :members_serialized, :categories_serialized, :perfect_tasks_serialized
  attribute :chart, if: :chart_serialized
  attribute :members, if: :members_serialized
  attribute :categories, if: :categories_serialized

  def initialize(project, options = {})
    super(project)
    @begin_date = options[:begin_date] || nil
    @end_date = options[:end_date] || nil
    @view = options[:view] || nil

    @chart_serialized = false
    @chart_serialized = options[:chart_serialized] unless options[:chart_serialized].nil?

    @members_serialized = true
    @members_serialized = options[:members_serialized] unless options[:members_serialized].nil?

    @categories_serialized = false
    @categories_serialized = options[:categories_serialized] unless options[:categories_serialized].nil?

    @perfect_tasks_serialized = false
    @perfect_tasks_serialized = options[:perfect_tasks_serialized] unless options[:perfect_tasks_serialized].nil?
  end

  def client
    ClientSerializer.new(object.client)
  end

  def tracked_time
    object.tracked_time(@begin_date, @end_date)
  end

  def members
    member_list = []
    object.unarchived_members.each do |project_member|
      item = {}
      item.merge!(MembersSerializer.new(project_member.member))
      item[:is_pm] = project_member.is_pm
      member_list.push(item)
    end
    member_list
  end

  def categories
    categories = object.unarchived_categories
    options = { each_serializer: CategorySerializer, begin_date: @begin_date, end_date: @end_date, perfect_tasks_serialized: @perfect_tasks_serialized }
    ActiveModel::Serializer::CollectionSerializer.new(categories, options)
  end

  def chart
    case @view
    when 'day'
      object.day_chart(@begin_date, @end_date)
    when 'month'
      object.month_chart(@begin_date, @end_date)
    when 'year'
      object.year_chart(@begin_date, @end_date)
    end
  end
end
