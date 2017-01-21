class ProjectCategorySerializer < ActiveModel::Serializer
    include Rails.application.routes.url_helpers

    has_one :category
    # has_many :project_category_users
end
