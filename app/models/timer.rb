class Timer < ApplicationRecord
    belongs_to :task

    validate :time_valid

    def get_tracked_time
        stop_time - start_time
    end

    private
    def time_valid
        errors.add(:start_time,'Start time have to less than stop time') if self.start_time >= self.stop_time
    end
end
