class CompanyJob < ApplicationRecord
    belongs_to :company
    belongs_to :job
    has_many :jobs_members

    validates_presence_of :job_id, :company_id
    validates_uniqueness_of :job_id, scope: [:company_id]
end
