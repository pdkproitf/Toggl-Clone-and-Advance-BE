class JobsMember < ApplicationRecord
    belongs_to :member, -> {where(is_archived: false)}
    belongs_to :job
    belongs_to :company

    validates_presence_of :job_id, :company_id
    validates_uniqueness_of :member_id, scope: [:job_id, :company_id]
end
