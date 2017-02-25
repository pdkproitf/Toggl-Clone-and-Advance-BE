class Timer < ApplicationRecord
    belongs_to :task

    def tracked_time
        stop_time - start_time
    end
end
