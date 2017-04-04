class Role < ApplicationRecord
    has_many :members, -> {where(is_archived: false)}

    validates :name, presence: true, length: { minimum: Settings.role_min_length },
                     uniqueness: { case_sensitive: false }
end
