class Role < ApplicationRecord
    has_many :members, -> {where(is_archived: false)}
end
