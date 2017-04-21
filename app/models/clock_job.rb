class ClockJob < ApplicationRecord
  has_many :schedulers

  validates :name, presence: true
end
