class Client < ApplicationRecord
    has_many :projects
    belongs_to :company
    validates :name, presence: true
    validates_uniqueness_of :name, scope: [:company_id]
end
