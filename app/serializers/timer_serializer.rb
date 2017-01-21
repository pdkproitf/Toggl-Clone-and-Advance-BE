class TimerSerializer < ActiveModel::Serializer
    include Rails.application.routes.url_helpers

    attributes :id, :start_time, :stop_time
end
