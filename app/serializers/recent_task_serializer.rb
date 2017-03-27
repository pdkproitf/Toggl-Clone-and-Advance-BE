class RecentTaskSerializer < ActiveModel::Serializer
  attributes :id, :name, :category_member_id, :project_name,
             :category_name, :background

  def project_name
    object.category_member.category.project.name
  end

  def category_name
    object.category_member.category.name
  end

  def background
    object.category_member.category.project.background
  end
end
