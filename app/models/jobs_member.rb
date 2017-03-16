class JobsMember < ApplicationRecord
  belongs_to :member
  belongs_to :job
end
