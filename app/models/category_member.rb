class CategoryMember < ApplicationRecord
    belongs_to :category, optional: true
    belongs_to :member
    has_many :tasks, dependent: :destroy
    validates_uniqueness_of :category_id, scope: :member_id, if: 'category_id.present?'

    def get_tracked_time
        sum = 0
        if tasks
            tasks.each do |task|
                sum += task.get_tracked_time
            end
        end
        sum
    end

    def archive
        if update_attributes(is_archived: true)
            true
        else
            error!(I18n.t('archive_failed'))
        end
    end

    def unarchive
        if update_attributes(is_archived: false)
            true
        else
            error!(I18n.t('unarchive_failed'))
        end
    end
end
