class Job < ApplicationRecord
    has_and_belongs_to_many :members

    validates :name, presence: true, uniqueness: false;
end
