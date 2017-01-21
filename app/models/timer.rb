class Timer < ApplicationRecord
    belongs_to :task, optional: true
end
