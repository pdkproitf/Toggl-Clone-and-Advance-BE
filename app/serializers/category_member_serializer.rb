class CategoryMemberSerializer < ActiveModel::Serializer
    attributes :id, :member_id, :category_id, :tracked_time

    def initialize(category, options = {})
      super(category)
      @begin_date = options[:begin_date] || nil
      @end_date = options[:end_date] || nil
    end

    def tracked_time
        object.tracked_time(@begin_date, @end_date)
    end

    def member_id
        object.project_member.member_id
    end
end
