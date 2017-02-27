class CategorySerializer < ActiveModel::Serializer
    attributes :id, :name, :tracked_time, :members
    def tracked_time
        object.get_tracked_time
    end

    def members
        list = []
        object.category_members.each do |category_member|
            item = {}
            item.merge!(MembersSerializer.new(category_member.member))
            item[:category_member_id] = category_member.id
            item[:tracked_time] = category_member.get_tracked_time
            list.push(item)
        end
        list
    end
end
