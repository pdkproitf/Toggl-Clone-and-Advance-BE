class ProjectCategoryMemberSerializer < ActiveModel::Serializer
    include Rails.application.routes.url_helpers

    attributes :id, :project_category_id, :member_id
end
