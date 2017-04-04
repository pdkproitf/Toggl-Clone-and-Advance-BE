class Job < ApplicationRecord
    has_many :company_jobs
    has_many :jobs_members, through: :company_jobs, source: :jobs_members
    has_many :members, through: :jobs_members
    has_many :companies, through: :company_jobs, source: :company
    validates :name, presence: true, uniqueness: true
end
