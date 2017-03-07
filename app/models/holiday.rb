class Holiday < ApplicationRecord
  validates :name, presence: true, length: { minimum: 1 }
  validates :company_id, presence: true
  validates :begin_day, presence: true
  validates :end_day, presence: true, date: { after_or_equal_to: :begin_day }
  validates_uniqueness_of :name, scope: [:company_id, :begin_day]

  belongs_to :company
end
