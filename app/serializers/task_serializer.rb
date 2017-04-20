class TaskSerializer < ActiveModel::Serializer
  attributes :id, :name
  attr_reader :tracked_time
  attribute :tracked_time

  def initialize(task, options = {})
    super(task)
    @begin_date = options[:begin_date] || nil
    @end_date = options[:end_date] || nil
  end

  def tracked_time
    object.tracked_time(@begin_date, @end_date)
  end
end
