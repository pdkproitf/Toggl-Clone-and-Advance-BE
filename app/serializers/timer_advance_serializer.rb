class TimerAdvanceSerializer < ActiveModel::Serializer
    attributes :id, :start_time, :stop_time, :tracked_time

    def tracked_time
        object.tracked_time
    end
end
