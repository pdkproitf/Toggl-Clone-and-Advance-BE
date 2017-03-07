class CategorySerializer < ActiveModel::Serializer
  attributes :id, :name, :is_billable, :tracked_time, :members
  def tracked_time
    object.get_tracked_time
  end

  def members
    list = []
    object.category_members.where(category_members: { is_archived: false })
          .each do |category_member|
      item = {}
      item.merge!(MembersSerializer.new(category_member.member))
      item[:is_pm] = category_member.member
                                    .project_members
                                    .find_by(project_id: object.project_id)
                                    .is_pm
      item[:category_member_id] = category_member.id
      item[:tracked_time] = category_member.get_tracked_time
      list.push(item)
    end
    list
  end
end
