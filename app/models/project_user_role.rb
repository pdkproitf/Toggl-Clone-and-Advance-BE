class ProjectUserRole < ApplicationRecord
    belongs_to :project
    belongs_to :user
    belongs_to :role, optional: true

    # def is_Admin?
    #     if self.role && self.role.name == 'Admin'
    #         return true;
    #     return false;
    # end
    #
    # def is_PM?
    #     if self.role && self.role.name == 'PM'
    #         return true;
    #     return false;
    # end
end
