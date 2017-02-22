class Category < ApplicationRecord
    belongs_to :project
    has_many :category_members
    validates :name, presence: true, length: { minimum: 1 }
    validates_uniqueness_of :name, scope: :project_id
end
