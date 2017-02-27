class CategorySerializer < ActiveModel::Serializer
    attributes :id, :name, :tracked_time, :members
    has_many :members, serializer: MembersSerializer
    def tracked_time
        object.get_tracked_time
    end

    def members
        list = []
        object.members.each do |member|
            item = {}
            item.merge!(MembersSerializer.new(member))
            item[:tracked_time] = member.category_member.get_tracked_time
            list.push(item)
        end
    end
end
