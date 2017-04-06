class CompanyJob < ApplicationRecord
    belongs_to :company
    belongs_to :job
    has_many :jobs_members, dependent: :destroy
    has_many :members, through: :jobs_members, source: :member

    validates_presence_of :job_id, :company_id
    validates_uniqueness_of :job_id, scope: [:company_id]
end
