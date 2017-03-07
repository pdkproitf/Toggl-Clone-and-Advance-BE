class ReportProjectByTimeSerializer < ActiveModel::Serializer
  attributes :id, :name, :client, :background, :tracked_time

  def client
    ClientSerializer.new(object.client)
  end

  def tracked_time
    object.get_tracked_time
  end
end
