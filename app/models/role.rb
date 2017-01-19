class Role < ApplicationRecord
    has_many :project_user_roles
end
