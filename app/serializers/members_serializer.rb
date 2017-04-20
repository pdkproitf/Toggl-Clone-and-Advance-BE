class MembersSerializer < ActiveModel::Serializer
  attributes :id, :total_day_off
  belongs_to :company, serializer: CompaniesSerializer
  belongs_to :user, serializer: UserSerializer
  belongs_to :role, serializer: RolesSerializer
  has_many   :jobs
  attr_reader :tracked_time_serialized
  attribute :tracked_time, if: :tracked_time_serialized
  attr_reader :chart_limit, :chart_serialized
  attribute :chart, if: :chart_serialized

  def initialize(member, options = {})
    super(member)
    @begin_date = options[:begin_date] || nil
    @end_date = options[:end_date] || nil
    @chart_limit = 366
    @chart_serialized = false
    unless options[:chart_serialized].nil?
      @chart_serialized = options[:chart_serialized]
    end
    @tracked_time_serialized = false
    unless options[:tracked_time_serialized].nil?
      @tracked_time_serialized = options[:tracked_time_serialized]
    end
  end

  def tracked_time
    object.tracked_time(@begin_date, @end_date)
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
end
