class ReportTaskSerializer < ActiveModel::Serializer
  attributes :id, :name, :category_member_id, :project_id, :project_name,
             :category_name, :background, :client, :tracked_time

  def initialize(task, options = {})
    super(task)
    @begin_date = options[:begin_date] || nil
    @end_date = options[:end_date] || nil
  end

  def project_id
    object.category_member.category.project.id
  end

  def project_name
    object.category_member.category.project.name
  end

  def category_name
    object.category_member.category.name
  end

  def background
    object.category_member.category.project.background
  end

  def client
    ClientSerializer.new(object.category_member.category.project.client)
  end

  def tracked_time
    object.tracked_time(@begin_date, @end_date)
  end
end
