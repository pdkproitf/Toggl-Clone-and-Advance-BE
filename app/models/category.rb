class Category < ApplicationRecord
    validates :name, presence: true, uniqueness: true
    has_many :project_categories, dependent: :destroy
end
