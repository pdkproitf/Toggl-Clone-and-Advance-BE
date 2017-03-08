class CategorySerializer < ActiveModel::Serializer
  attributes :id, :name, :is_billable, :tracked_time, :members
  def tracked_time
    object.tracked_time
  end

  def members
    list = []
    object.category_members.where(is_archived: false).each do |category_member|
      item = {}
      item.merge!(MembersSerializer.new(category_member.project_member.member))
      item[:is_pm] = category_member.project_member.is_pm
      item[:category_member_id] = category_member.id
      item[:tracked_time] = category_member.tracked_time
      list.push(item)
    end
    list
  end
end
