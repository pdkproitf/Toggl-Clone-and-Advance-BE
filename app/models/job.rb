class Job < ApplicationRecord
    has_many :jobs_members
    has_many :members, :through => :jobs_members

    validates :name, presence: true, uniqueness: true
end
