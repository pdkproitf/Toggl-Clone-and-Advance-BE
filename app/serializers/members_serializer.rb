class MembersSerializer < ActiveModel::Serializer
  attributes :id, :furlough_total
  belongs_to :company, serializer: CompaniesSerializer
  belongs_to :user, serializer: UserSerializer
  belongs_to :role, serializer: RolesSerializer
  attr_reader :is_tracked_time_serialized
  attribute :tracked_time, if: :is_tracked_time_serialized
  # attr_reader :chart_limit, :chart_serialized
  # attribute :chart, if: :chart_serialized

  def initialize(member, options = {})
    super(member)
    @begin_date = options[:begin_date] || nil
    @end_date = options[:end_date] || nil
    @chart_limit = 50
    @chart_serialized = false
    unless options[:chart_serialized].nil?
      @chart_serialized = options[:chart_serialized]
      puts '----------------'
      puts @chart_serialized
      puts '----------------'
    end
    @is_tracked_time_serialized = false
    unless options[:is_tracked_time_serialized].nil?
      @is_tracked_time_serialized = options[:is_tracked_time_serialized]
    end
  end

  def tracked_time
    sum = 0
    assigned_category_members.each do |category_member|
      sum += category_member.tracked_time(@begin_date, @end_date)
    end
    sum
  end

  def chart
    chart = []
    count = 0
    (@begin_date..@end_date).each do |date|
      item = {}
      item[date] = {}
      billable_total = 0
      unbillable_total = 0
      assigned_category_members.each do |category_member|
        if category_member.category.is_billable == true
          billable_total += category_member.tracked_time(date, date)
        else
          unbillable_total += category_member.tracked_time(date, date)
        end
      end
      item[date][:billable] = billable_total
      item[date][:unbillable] = unbillable_total
      chart.push(item)
      count += 1
      break if count == @chart_limit
    end

    chart
  end

  def assigned_category_members
    object
      .category_members
      .where.not(category_id: nil)
      .where(category_members: { is_archived_by_category: false })
      .where(category_members: { is_archived_by_project_member: false })
      .joins(category: :project)
  end
end
