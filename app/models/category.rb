class Category < ApplicationRecord
    validates :name, presence: true, length: { minimum: 1 }
    has_many :project_categories, dependent: :destroy
    belongs_to :project, optional: true
    validates_uniqueness_of :name, scope: :project_id
end
