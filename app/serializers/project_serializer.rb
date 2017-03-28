class ProjectSerializer < ActiveModel::Serializer
  attributes :id, :name, :client, :background,
             :is_member_report, :tracked_time
  attr_reader :chart_limit, :chart_serialized,
              :members_serialized, :categories_serialized
  attribute :chart, if: :chart_serialized
  attribute :members, if: :members_serialized
  attribute :categories, if: :categories_serialized

  def initialize(project, options = {})
    super(project)
    @begin_date = options[:begin_date] || nil
    @end_date = options[:end_date] || nil
    @chart_limit = 366
    @chart_serialized = false
    @chart_serialized = options[:chart_serialized] unless options[:chart_serialized].nil?
    @members_serialized = true
    @members_serialized = options[:members_serialized] unless options[:members_serialized].nil?
    @categories_serialized = false
    @categories_serialized = options[:categories_serialized] unless options[:categories_serialized].nil?
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
    options = { each_serializer: CategorySerializer, begin_date: @begin_date, end_date: @end_date }
    ActiveModel::Serializer::CollectionSerializer.new(categories, options)
  end

  def chart
    case view_detected
    when 'day'
      day_chart
    when 'month'
      month_chart
    when 'year'
      year_chart
    end
  end

  private

  def day_chart
    chart = []
    (@begin_date..@end_date).take(@chart_limit).each do |date|
      item = {}
      item[date] = {}
      item[date] = category_tracked_time(date, date)
      chart.push(item)
    end
    chart
  end

  def month_chart
    # Chart of month that begin_date belongs to (Calculate from begin_date)

    # Number of months between the month of begin_date and the month of end_date
    number_of_months = @end_date.month - @begin_date.month - 1
    (1..number_of_months).each do |i|
      p i
    end
    # Chart of months between the month of begin_date and the month of end_date
    # Chart of month that end_date belongs to (Calculate to end_date)
  end

  def year_chart
    'year_chart'
  end

  def view_detected
    # Date.leap?(begin_date.year)
    if (@end_date - @begin_date).to_i <= 31
      'day'
    elsif (@end_date - @begin_date).to_i <= 366
      'month'
    else
      'year'
    end
  end

  def category_tracked_time(begin_date, end_date)
    billable_total = 0
    unbillable_total = 0
    object.categories.each do |category|
      if category.is_billable == true
        billable_total += category.tracked_time(begin_date, end_date)
      else
        unbillable_total += category.tracked_time(begin_date, end_date)
      end
    end
    {
      billable: billable_total,
      unbillable: unbillable_total
    }
  end
end
