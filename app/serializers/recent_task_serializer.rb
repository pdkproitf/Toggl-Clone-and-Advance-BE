class RecentTaskSerializer < ActiveModel::Serializer
    attributes :id, :name, :project_name, :category_name, :background

    def project_name
        object.category_member.category.project.name if has_category?
    end

    def category_name
        object.category_member.category.name if has_category?
    end

    def background
        object.category_member.category.project.background if has_category?
    end

    def has_category?
        if object.category_member.category
            true
        else
            false
        end
    end
end
