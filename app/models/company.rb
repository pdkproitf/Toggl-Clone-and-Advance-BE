class Company < ApplicationRecord
    VALID_DOMAIN_REGEX = /\A[\w0-9+\-.]+[a-z0-9]+\z/i

    has_many :members, dependent: :destroy
    has_many :users, through: :members
    has_many :clients
    has_many :invites

    validates :name,    presence: true, uniqueness: true
    validates :domain,  presence: true, uniqueness: true,
                        length: { minimum: 4, maximum: 30 },
                        format: { with: VALID_DOMAIN_REGEX }
end
