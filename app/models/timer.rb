class Timer < ApplicationRecord
    belongs_to :task

    validate :time_valid

    def tracked_time
        stop_time - start_time
    end

    private

    def time_valid
        errors.add(:start_time, 'Start time have to less than stop time') if start_time >= stop_time
    end
end
