class Project < ApplicationRecord
    belongs_to :member
    has_one :client
    has_many :categories, dependent: :destroy
    has_many :project_members, dependent: :destroy
    has_many :members, through: :project_members

    validates :name, presence: true
    validates :client_id, presence: true
    validates :member_id, presence: true
    validates_uniqueness_of :name, scope: [:client_id, :member_id]

    def get_tracked_time
        sum = 0
        if project_categories
            project_categories.each do |pc|
                sum += pc.get_tracked_time
            end
        end
        sum
    end

    def get_all_members(order_by = '')
        order_by = case order_by
                   when 'id'
                       'users.id'
                   when 'last_name'
                       'users.last_name'
                   else
                       'users.first_name'
                   end
        pur_list = Project.where(id: id)
                          .left_outer_joins(project_user_roles: [:user, :role])
                          .select('project_user_roles.id', 'project_user_roles.project_id', 'project_user_roles.user_id')
                          .select('users.first_name', 'users.last_name')
                          .select('users.email', 'users.image')
                          .select('roles.id as role_id', 'roles.name as role_name')
                          .order(order_by) # order_by + ' desc'

        return [] if pur_list.first.id.nil?
        user_list = []
        pur_list.each do |pur|
            item = user_list.select do |hash|
                hash[:id] == pur.user_id
            end
            if item == []
                item = { id: pur.user_id, first_name: pur.first_name, last_name: pur.last_name }
                item[:email] = pur.email
                item[:image] = pur.image
                if pur.role_id.nil?
                    item[:role] = nil
                    user_list.push(item)
                    next
                end
                item[:role] = []
                user_list.push(item)
            else
                item = item.first
            end
            item[:role].push(id: pur.role_id, name: pur.role_name)
        end
        user_list
    end
end
