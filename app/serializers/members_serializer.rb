class MembersSerializer < ActiveModel::Serializer
  attributes :id, :furlough_total
  belongs_to :company, serializer: CompaniesSerializer
  belongs_to :user, serializer: UserSerializer
  belongs_to :role, serializer: RolesSerializer

  attribute :tracked_time, if: :is_tracked_time_serialized
  # has_many :members, serializer: MembersSerializer

  def initialize(member, options = {})
    super(member)
    @begin_date = options[:begin_date] || nil
    @end_date = options[:end_date] || nil
    @is_tracked_time_serialized = false
    unless options[:is_tracked_time_serialized].nil?
      @is_tracked_time_serialized = options[:is_tracked_time_serialized]
    end
  end

  attr_reader :is_tracked_time_serialized

  def tracked_time
    sum = 0
    category_members = object.category_members
    category_members.each do |category_member|
      sum += category_member.tracked_time(@begin_date, @end_date)
    end
    sum
  end
end
