class Timer < ApplicationRecord
    belongs_to :task

    def get_tracked_time
        stop_time - start_time
    end
end
