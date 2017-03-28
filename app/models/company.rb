class Company < ApplicationRecord
    has_many :members, -> {where(is_archived: false)}, dependent: :destroy
    has_many :users, through: :members
    has_many :clients
    has_many :invites
    has_many :projects, through: :members
    has_many :holidays, dependent: :destroy

    VALID_DOMAIN_REGEX = /\A[\w0-9+\-.]+[a-z0-9]+\z/i
    # validates :name,    presence: true, uniqueness: true, length: { minimum: 3, maximum: 100 }
    validates :domain,  presence: true, uniqueness: true,
        length: { minimum: Settings.domain_min_length, maximum: Settings.domain_max_length },
        format: { with: VALID_DOMAIN_REGEX }
end
