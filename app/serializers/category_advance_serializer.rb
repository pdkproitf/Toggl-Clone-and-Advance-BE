class CategoryAdvanceSerializer < ActiveModel::Serializer
    attributes :id, :name, :tracked_time, :is_billable

    def initialize(category, options = {})
      super(category)
      @begin_date = options[:begin_date] || nil
      @end_date = options[:end_date] || nil
    end

    def tracked_time
        object.tracked_time(@begin_date, @end_date)
    end
end
