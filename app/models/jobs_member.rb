class JobsMember < ApplicationRecord
    belongs_to :member, -> {where(is_archived: false)}
    belongs_to :job
    validates_uniqueness_of :member_id, scope: [:job_id]
end
