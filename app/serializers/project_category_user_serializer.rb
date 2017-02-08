class ProjectCategoryUserSerializer < ActiveModel::Serializer
    include Rails.application.routes.url_helpers

    attributes :id, :project_category_id, :user_id
end
