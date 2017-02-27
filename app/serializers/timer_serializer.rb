class TimerSerializer < ActiveModel::Serializer
    attributes :id, :task, :start_time, :stop_time, :cm_id, :project_name, :category_name, :background
    belongs_to :task, serializer: TaskSerializer

    def cm_id
        object.task.category_member.id
    end

    def project_name
        category = object.task.category_member.category
        return nil unless category
        category.project.name
    end

    def category_name
        category = object.task.category_member.category
        return nil unless category
        category.name
    end

    def background
        category = object.task.category_member.category
        return nil unless category
        category.project.background
    end
end
