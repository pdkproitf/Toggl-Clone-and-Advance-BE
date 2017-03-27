class Holiday < ApplicationRecord
  belongs_to :company

  validates :name, presence: true, length: { minimum: 1 }
  validates :company_id, presence: true
  validates :begin_date, presence: true
  validates :end_date, presence: true
  validates_uniqueness_of :name, scope: [:company_id, :begin_date]
  validate :begin_date_cannot_be_greater_than_end_date

  def begin_date_cannot_be_greater_than_end_date
    errors.add(:begin_date, "can't be greater than end date") if begin_date > end_date
  end
end
