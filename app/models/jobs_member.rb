class JobsMember < ApplicationRecord
    belongs_to :member, -> {where(is_archived: false)}
    belongs_to :company_job
    has_one :job, through: :company_job, source: :job
    has_one :company, through: :company_job, source: :company

    validates_presence_of :member_id, :company_job_id
    validates_uniqueness_of :member_id, scope: [:company_job_id]
end
