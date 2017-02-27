class TimerSerializer < ActiveModel::Serializer
    attributes :id, :task, :start_time, :stop_time
end
