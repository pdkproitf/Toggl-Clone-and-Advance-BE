class ProjectCategoryUserSerializer < ActiveModel::Serializer
    include Rails.application.routes.url_helpers

    attributes :id
    has_one :project_category
end
