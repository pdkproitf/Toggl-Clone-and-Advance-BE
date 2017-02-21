class Company < ApplicationRecord
    belongs_to :user
    has_many :members, dependent: :destroy
    has_many :users, through: :members
    has_many :invites

    validates :domain, presence: true, uniqueness: true
end
