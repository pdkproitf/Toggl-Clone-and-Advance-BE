class Scheduler < ApplicationRecord
  belongs_to :clock_job
  belongs_to :company

  validates :name, :frequency, :clock_job_id, presence: true
end
