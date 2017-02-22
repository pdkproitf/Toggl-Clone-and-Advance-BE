class ProjectCategorySerializer < ActiveModel::Serializer
    include Rails.application.routes.url_helpers

    attributes :id, :project_id, :category_id, :is_billable
end
