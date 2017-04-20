class Holiday < ApplicationRecord
    belongs_to :company

    validates :name, length: { minimum: 2 }
    validates_presence_of :begin_date, :end_date, :company_id
    validate :valid_start_end_days

    after_save  :increase_dayoffs
    before_update :decrease_dayoffs
    before_destroy :decrease_dayoffs

    private
    include DaysValidates

    # begin_date_cannot_be_greater_than_end_date
    def valid_start_end_days
        days_valid?(begin_date, 'begin_date', end_date)
    end

    def increase_dayoffs
        compare(company.timeoffs.where(status: TimeOff.statuses[:approved]))
    end

    def decrease_dayoffs
        if(destroyed?)
            compare(company.timeoffs.where(status: TimeOff.statuses[:approved]), false)
        else
            compare(company.timeoffs.where(status: TimeOff.statuses[:approved]), false, begin_date_was, end_date_was)
        end
    end

    def compare(timeoffs, is_plus = true, begin_date = self.begin_date, end_date = self.end_date)
        conflict_timeoff = (conflict_begin_date(0, timeoffs, begin_date, "time_offs.start_date", end_date, "time_offs.end_date", "time_offs.id")) +
            (conflict_end_date(0, timeoffs, begin_date, "time_offs.start_date", end_date, "time_offs.end_date", "time_offs.id")) +
            (conflict_middle_date(0, timeoffs, begin_date, "time_offs.start_date", end_date, "time_offs.end_date", "time_offs.id"))

        unless conflict_timeoff.blank?
            conflict_timeoff.uniq!
            conflict_timeoff.each do |timeoff|
                similar_day = similar_days(timeoff, begin_date, end_date)

                total_day_off = (is_plus)? (timeoff.sender.total_day_off + similar_day) : (timeoff.sender.total_day_off - similar_day)
                day_offed = (is_plus)? (timeoff.sender.day_offed - similar_day) : (timeoff.sender.day_offed + similar_day)

                timeoff.sender.update_attributes!(total_day_off: total_day_off, day_offed: day_offed)
            end
        end
    end

    # compute bettween two phase_days
    def similar_days(timeoff, begin_date, end_date)
        similar_day = 0
        (begin_date.to_i .. end_date.to_i).step(1.day).each do |day|
            if(day == timeoff.start_date.to_i)
                similar_day += (timeoff.is_start_half_day)? 0.5 : 1
            elsif(day == timeoff.end_date.to_i)
                similar_day += (timeoff.is_end_half_day)? 0.5 : 1
            elsif(timeoff.start_date.to_i < day && timeoff.end_date.to_i > day)
                similar_day += 1
            end
        end
        similar_day
    end
end
