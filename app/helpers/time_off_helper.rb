module TimeOffHelper
    def create_timeoff
        TimeOff.create!(create_params)
    end

    def create_params
        params['timeoff'].store('sender_id', @current_member.id)
        ActionController::Parameters.new(params).require(:timeoff).permit(:sender_id, :start_date, :end_date, :is_start_half_day, :is_end_half_day, :description)
    end

    def send_email_to_boss timeoff
        send_mail_to = (company_boss_without_current_member + project_pm_boss_without_current_member).uniq
        send_mail_to.each{ |member| TimeOffMailer.timeoff_announce(timeoff, member.user.email).deliver_later(wait: 10.seconds)}
    end

    def company_boss_without_current_member
        role_ad_pm = []
        Role.where('name = ? OR name = ?', 'Admin', 'PM').each{|role| role_ad_pm.push(role.id)}
        @current_member.company.members.where('id NOT IN (?) and role_id IN (?)',@current_member.id ,role_ad_pm)
    end

    def project_pm_boss_without_current_member
        project_join = get_project_joining_without_archived
        project_pms = ProjectMember.where('project_id IN (?) and is_pm = ? and member_id NOT IN (?) ', project_join, true, @current_member.id)
        project_pms.map{|project_pm| project_pm.member}
    end

    def get_project_joining_without_archived
        project_join = []
        @current_member.project_members.each{|p_member| project_join.push(p_member.project_id) unless p_member.project.is_archived}
        project_join
    end

    def update_timeoff
        @timeoff.update_attributes!(create_params)
        send_email_to_boss @timeoff
        return_message 'Success'
    end

    # true if timeoff didn't belong to current_member & current_member is admin or (PM and timeoff's sender  is member)
    def able_to_answer_request?
        return false if @current_member.id == @timeoff.sender_id
        return true if @current_member.admin?
        return true if @current_member.pm? & @timeoff.sender.member?
        false
    end

    def answer_timeoff
        @timeoff.update_attributes!(
        approver_id: @current_member.id,
        approver_messages: params['answer_timeoff_request']['approver_messages'],
        status: params['answer_timeoff_request']['status'])
        send_answer_to_person_relative @timeoff
        return_message 'Success'
    end

    def send_answer_to_person_relative timeoff
        send_mail_to = (company_boss_without_current_member + project_pm_boss_without_current_member)
        send_mail_to.push(@timeoff.sender)
        send_mail_to.reject!{|x| x.id == @current_member.id}
        send_mail_to.uniq
        send_mail_to.each{ |member| TimeOffMailer.timeoff_announce(timeoff, member.user.email, @current_member).deliver_later(wait: 5.seconds)}
    end

    def admin_delete
        @timeoff.destroy!
        send_answer_to_person_relative @timeoff
        return_message 'Success!, Your timeoff was deleted!', @timeoff
    end

    def sender_delete
        return return_message "Error Access Denied! You can't delete this Request" unless @timeoff.sender_id == @current_member.id
        return return_message "Not Allow!  Your request was answered. You can contact with admin to delete this request" unless @timeoff.pending?

        @timeoff.destroy!
        return_message 'Success!, Your timeoff was deleted!', @timeoff
    end
end
