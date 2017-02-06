class TaskSerializer < ActiveModel::Serializer
    include Rails.application.routes.url_helpers

    attributes :id, :name
    has_one :project_category_users
    has_many :timers
end