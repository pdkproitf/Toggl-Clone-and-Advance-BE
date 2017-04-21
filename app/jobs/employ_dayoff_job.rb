class EmployDayoffJob < ApplicationJob
    queue_as :default

    def perform(*args)
        p "chay vo day "
        reset_dayoff(Company.all) if beginning_of_year? || beginning_of_june?
    end

    def reset_dayoff(companies)
        companies.each{|company| begin_year(company)} if beginning_of_year?
        companies.each{|company| middle_year(company)} if beginning_of_june?
    end

    def begin_year(company)
        company.members.each do |member|
            previous_dayoff = member.total_day_off
            new_dayoff = Settings.begin_year_dayoff + (company.incre_dayoff)? previous_dayoff : 0
            member.update_attributes!(total_day_off: new_dayoff, day_offed: Settings.reset_dayoffed)
        end
    end

    def middle_year(company)
        company.members.each do |member|
            limit_dayoff = Settings.begin_year_dayoff + Settings.limit_dayoff_old
            member.update_attributes!(total_day_off: limit_dayoff) if member.total_day_off > limit_dayoff
        end
    end

    def beginning_of_year?
        Date.today == Date.today.beginning_of_year
    end

    def beginning_of_june?
        (Date.today.month == 6) && (Date.today == Date.today.beginning_of_month)
    end
end
