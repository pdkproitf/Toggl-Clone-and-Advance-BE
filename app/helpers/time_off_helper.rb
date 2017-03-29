module TimeOffHelper
    def create_timeoff
        params['timeoff'].store('sender_id', @current_member.id)
        TimeOff.create!(create_params)
    end

    def create_params
        ActionController::Parameters.new(params).require(:timeoff)
            .permit(:sender_id, :start_date, :end_date, :is_start_half_day, :is_end_half_day, :description)
    end

    # send email to sender's boss include current Project Manages
    def inform_request(timeoff)
        timeoff.send_email (company_boss + project_pm_boss).uniq
    end

    # find company's boss without current_member
    def company_boss
        role_ad_pm = []
        Role.where('name = ? OR name = ?', 'Admin', 'PM').each{|role| role_ad_pm.push(role.id)}

        @current_member.company.members
            .where('id NOT IN (?) and role_id IN (?)',@current_member.id ,role_ad_pm)
    end

    # find project_pm's boss without current_member
    def project_pm_boss
        project_join = get_project_joining
        project_pms = ProjectMember
            .where('project_id IN (?) and is_pm = ? and member_id NOT IN (?)',
                project_join, true, @current_member.id)
        project_pms.map{|project_pm| project_pm.member}
    end

    # get project that user joining wihout archived
    def get_project_joining
        project_join = []
        @current_member.project_members.each do |p_member|
            project_join.push(p_member.project_id) unless !p_member.project.blank? && p_member.project.is_archived
        end
        project_join
    end

    def update_timeoff
        @timeoff.update_attributes!(create_params)

        inform_request(@timeoff)
        return_message I18n.t("success")
    end

    # true if timeoff didn't belong to current_member
    # && current_member is admin or (PM and timeoff's sender  is member)
    def able_answer_request?(current_member = nil, timeoff = nil)
        current_member = current_member || @current_member
        timeoff = timeoff || @timeoff

        return false if current_member.id == timeoff.sender_id
        return true if current_member.admin? || current_member.pm? && timeoff.sender.member?
        false
    end

    def answer_timeoff
        @timeoff.update_attributes!(
            approver_id: @current_member.id,
            approver_messages: params['answer_timeoff_request']['approver_messages'],
            status: params['answer_timeoff_request']['status'])

        confirm_request(@timeoff)
        return_message I18n.t("success")
    end

    # send email to notice that request confirmed
    def confirm_request(timeoff)
        send_mail_to = (company_boss + project_pm_boss)
        send_mail_to.push(@timeoff.sender)
        send_mail_to.reject!{|x| x.id == @current_member.id}

        timeoff.send_email(send_mail_to.uniq, @current_member)
    end

    # delete request with admin role
    def admin_delete
        @timeoff.destroy!
        confirm_request(@timeoff)
        return_message I18n.t("success"), @timeoff
    end

    # delete request with sender role
    def sender_delete
        error!(I18n.t("access_denied"), 403) unless @timeoff.sender_id == @current_member.id
        error!(I18n.t("timeoff.errors.request_answed")) unless @timeoff.pending?

        @timeoff.destroy!
        return_message I18n.t('success'), @timeoff
    end

    # get all request
    def get_all
        data = TimeOff.all.map { |e| TimeOffSerializer.new(e)}
        return_message(I18n.t('success'), data)
    end

    # get timeoff request follow phase
    def get_phase
        (params['status'] == 'pending')? without_member_ordinal : member_ordinal
    end

    # using get timeoff of in phase for show person request and manage request
    # without ordinal member
    def without_member_ordinal
        off_requests = @current_member.off_requests.map {|e| TimeOffSerializer.new(e)}
        pending_requests = []
        pending_requests = TimeOff
            .where("start_date >= (?) and created_at <= (?) and status = ?" ,
                params['from_date'], params['to_date'], TimeOff.statuses[:pending])
            .map {|e| TimeOffSerializer.new(e)} if @current_member.admin? || @current_member.pm?

        return_message I18n.t("success"), {off_requests: off_requests, pending_requests: pending_requests}
    end

    # using get timeoff of member in company follow phase and # ordinal member
    def member_ordinal
        error!(I18n.t("access_denied"), 403) unless (@current_member.admin? || @current_member.pm?)
        timeoffs = []
        members = []
        @current_member.company.members.each do |member|
            timeoffs.push(member.off_requests
                .where('(start_date >= (?) and start_date <= (?)) or (end_date >= (?) and end_date <= (?))',
                    params['from_date'], params['to_date'], params['from_date'], params['to_date'] )
                .map {|e| TimeOffSerializer.new(e)})

            serialize_member = MembersSerializer.new(member)
            serialize_member = serialize_member.to_h
            serialize_member.merge!(future_dateoff(member))
            serialize_member.merge!(member_project_joined(member))

            members.push(serialize_member)
        end

        holidays = @current_member.company.holidays
            .where('(begin_date >= (?) and begin_date <= (?)) or (end_date >= (?) and end_date <= (?))',
                params['from_date'], params['to_date'], params['from_date'], params['to_date'])

        return_message I18n.t("Success"), {members: members, timeoffs: timeoffs, holidays: holidays}
    end

    # get projects joind of specify member
    def member_project_joined(member)
        projects = member.joined_projects.where(is_archived: false)
        { 'projects_joined': projects }
    end

    # get total future day off and the nearest day off in future
    def future_dateoff(member)
        today = Time.now.beginning_of_day
        today = params['to_date'].beginning_of_day if params['to_date'] > today

        future_dayoff = 0.0     #default num of future_dayoff
        previous_timeoff = nil  #defaul nearest_future_dateoff
        current_diff = nil      #using compute nearest day off

        member.off_requests.where('end_date > (?)  and status != ?', today, TimeOff.statuses[:rejected])
            .each do |timeoff|
                previous_timeoff = timeoff if previous_timeoff.nil?
                diff_day = find_nearest_day(timeoff, today)
                current_diff = diff_day if current_diff.nil?

                if diff_day < current_diff
                    current_diff = diff_day
                    previous_timeoff = timeoff
                end

                future_dayoff += compute_diff_dayoff(timeoff, today)
            end

        { nearest_future_dateoff: nearest_future_dateoff(previous_timeoff, today),
          future_dayoff:          future_dayoff }
    end

    def nearest_future_dateoff(previous_timeoff, today)
      return today if previous_timeoff.blank?
      return previous_timeoff.start_date if previous_timeoff.start_date > today
      return today + 1.day if previous_timeoff.start_date == today
      previous_timeoff.end_date
    end

    # compute future day off from today of specify timeoff
    def compute_diff_dayoff(timeoff, today)
        if today < timeoff.start_date
            ((timeoff.end_date.beginning_of_day - timeoff.start_date.beginning_of_day)/ 1.day
                + ((timeoff.is_start_half_day)? Settings.half_day : Settings.all_day)
                + ((timeoff.is_end_half_day)? Settings.half_day : Settings.all_day))
        elsif today == timeoff.start_date
            ((timeoff.end_date.beginning_of_day - timeoff.start_date.beginning_of_day)/1.day
                + ((timeoff.is_end_half_day)? Settings.half_day : Settings.all_day))
        else today > timeoff.start_date
            ((timeoff.end_date.beginning_of_day - today)/1.day
                + ((timeoff.is_end_half_day)? Settings.half_day : Settings.all_day))
        end
    end

    # compare today and start_date or end_date of timeoff to find nearest day
    def find_nearest_day(timeoff, today)
        if today < timeoff.start_date
            (timeoff.start_date.beginning_of_day - today)/ 1.day
        elsif today == timeoff.start_date
            today + 1.day
        else today > timeoff.start_date
            (timeoff.end_date.beginning_of_day - today)/1.day
        end
    end

    # get num offed day, and persons approved
    def offed_approver(off_dates)
        offed = 0
        approver = []
        off_dates.each do |timeoff|
            offed   += ((timeoff.end_date -  timeoff.start_date)/ 1.day)
                    + ((timeoff.is_start_half_day)? Settings.half_day : Settings.all_day)
                    + ((timeoff.is_end_half_day)? Settings.half_day : Settings.all_day)
            approver.push("#{timeoff.approver.user.first_name} #{timeoff.approver.user.last_name}")
        end
        { total: @current_member.furlough_total ,offed: offed, approver: approver }
    end
end
