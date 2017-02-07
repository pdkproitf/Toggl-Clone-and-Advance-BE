class MembershipSerializer < ActiveModel::Serializer
    include Rails.application.routes.url_helpers
    attributes :id
    has_one :employee
    # has_many :project_category_users
end
