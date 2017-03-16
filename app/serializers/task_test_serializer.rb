class TaskTestSerializer < ActiveModel::Serializer
  attributes :id, :name, :category_member_id, :project_name,
             :category_name, :background, :client, :tracked_time

  def initialize(task, options = {})
    super(task)
    @begin_date = options[:begin_date] || nil
    @end_date = options[:end_date] || nil
  end

  def project_name
    object.category_member.category.project.name if category?
  end

  def category_name
    object.category_member.category.name if category?
  end

  def background
    object.category_member.category.project.background if category?
  end

  def client
    if category?
      ClientSerializer.new(object.category_member.category.project.client)
    end
  end

  def tracked_time
    object.tracked_time(@begin_date, @end_date)
  end

  def category?
    if object.category_member.category
      true
    else
      false
    end
  end
end
