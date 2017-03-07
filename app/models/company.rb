class Company < ApplicationRecord
  VALID_DOMAIN_REGEX = /\A[\w0-9+\-.]+[a-z0-9]+\z/i

  has_many :members, dependent: :destroy
  has_many :users, through: :members
  has_many :clients
  has_many :invites
  has_many :projects, through: :members
  has_many :holidays, dependent: :destroy

  # validates :name,    presence: true, uniqueness: true, length: { minimum: 3, maximum: 100 }
  validates :domain,  presence: true, uniqueness: true,
                      length: { minimum: 3, maximum: 20 },
                      format: { with: VALID_DOMAIN_REGEX }
end
