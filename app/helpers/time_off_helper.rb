module TimeOffHelper
    def create_params
        params['timeoff'].store('sender_id', @current_member.id)
        ActionController::Parameters.new(params).require(:timeoff).permit(:sender_id, :start_date, :end_date, :is_start_half_day, :is_end_half_day, :description)
    end

    def create_timeoff
        TimeOff.create!(create_params)
    end

    def send_email_to_boss timeoff
        send_mail_to = (company_boss + project_pm_boss).uniq
        send_mail_to.each{ |member| TimeOffMailer.timeoff_announce(timeoff, @current_member, member.user.email).deliver_later(wait: 10.seconds)}
    end

    def company_boss
        role_ad_pm = []
        Role.where('name = ? OR name = ?', 'Admin', 'PM').each{|role| role_ad_pm.push(role.id)}
        @current_member.company.members.where('id NOT IN (?) and role_id IN (?)',@current_member.id ,role_ad_pm)
    end

    def project_pm_boss
        project_join = get_project_joining
        project_pms = ProjectMember.where('project_id IN (?) and is_pm = ? and member_id NOT IN (?) ', project_join, true, @current_member.id)
        project_pms.map{|project_pm| project_pm.member}
    end

    def get_project_joining
        project_join = []
        @current_member.project_members.each{|p_member| project_join.push(p_member.project_id)}
        project_join
    end
end
