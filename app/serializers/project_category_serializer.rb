class ProjectCategorySerializer < ActiveModel::Serializer
    include Rails.application.routes.url_helpers

    has_one :project
    has_one :category
end
