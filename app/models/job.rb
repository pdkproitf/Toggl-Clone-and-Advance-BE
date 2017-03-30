class Job < ApplicationRecord
    has_many :jobs_members
    has_many :members, through: :jobs_members
    has_many :companies, through: :members, source: :company
    validates :name, presence: true, uniqueness: true
end
