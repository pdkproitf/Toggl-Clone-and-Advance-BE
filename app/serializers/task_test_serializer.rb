class TaskTestSerializer < ActiveModel::Serializer
  attributes :id, :name, :category_member_id, :project_name,
             :category_name, :background

  def project_name
    object.category_member.category.project.name if category?
  end

  def category_name
    object.category_member.category.name if category?
  end

  def background
    object.category_member.category.project.background if category?
  end

  def category?
    if object.category_member.category
      true
    else
      false
    end
  end
end
