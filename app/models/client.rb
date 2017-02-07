class Client < ApplicationRecord
    validates :name, presence: true, uniqueness: true
    has_many :projects
    belongs_to :user
end
