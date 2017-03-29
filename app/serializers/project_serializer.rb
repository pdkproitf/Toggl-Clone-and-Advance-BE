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
      item[date] = category_tracked_time(date, date)
      chart.push(item)
    end
    chart
  end

  def month_chart
    chart = []
    # Chart of month that begin_date belongs to (Calculate from begin_date)
    # month_begin_date = @begin_date
    # month_end_date = Date.new(@begin_date.year, @begin_date.month, -1)
    # begin_month_key = @begin_date.strftime('%Y-%m')
    # end_month_key = @end_date.strftime('%Y-%m')
    # month_key = (month_end_date + 1).strftime('%Y-%m')
    #
    # month = {}
    # month[begin_month_key] = category_tracked_time(month_begin_date, month_end_date)
    # chart.push(month)

    # Chart of months between the month of begin_date and the month of end_date
    month = @begin_date.strftime('%Y-%m')
    next_end_date_month = (Date.new(@end_date.year, @end_date.month, -1) + 1).strftime('%Y-%m')
    return next_end_date_month
    # until month == end_month_key
    #   month_begin_date = month_end_date + 1
    #   month_end_date = Date.new(month_begin_date.year, month_begin_date.month, -1)
    #
    #   month = {}
    #   month[month_key] = category_tracked_time(month_begin_date, month_end_date)
    #   chart.push(month)
    #
    #   month_key = (month_end_date + 1).strftime('%Y-%m')
    # end

    # Chart of month that end_date belongs to (Calculate begin of month to end_date)
    # month = {}
    # month[month_key] = category_tracked_time(month_end_date + 1, @end_date)
    # chart.push(month)

    chart
  end

  def year_chart
    chart = []
    year = @begin_date.year
    until year == @end_date.year + 1
      year == @begin_date.year ? year_begin_date = @begin_date : year_begin_date = Date.new(year, 0o1, 0o1)
      year == @end_date.year ? year_end_date = @end_date : year_end_date = Date.new(year, 12, 31)

      columns = {}
      columns[year_begin_date.year] = category_tracked_time(year_begin_date, year_end_date)
      chart.push(columns)

      year += 1
    end

    chart
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
