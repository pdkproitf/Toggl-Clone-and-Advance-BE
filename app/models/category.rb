class Category < ApplicationRecord
    validates :name, presence: true, length: { minimum: 1 }
    belongs_to :project
    validates_uniqueness_of :name, scope: :project_id
end
