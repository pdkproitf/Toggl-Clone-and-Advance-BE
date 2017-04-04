module MemberHelper
    def able_see_member?(member)
        @current_member.manager? && (member.company_id == @current_member.company_id)
    end

    def able_modify_member?(member)
        able_see_member?(member) && @current_member.admin?
    end

    def update_role(role_id, member)
        member.update_attributes!(role_id: Role.find(role_id).id)
    end

    def update_jobs(new_jobs, member)
        job_removed(member.jobs, new_jobs, member)
        new_jobs.each do |id|
            member.jobs_members.find_or_create_by!(job_id: Job.find(id).id, company_id: member.company_id)
        end
    end

    # => find job was removed in front end and removed it
    def job_removed(current_jobs, new_jobs, member)
        current_jobs.reject{|x| new_jobs.include? x.id}
        member.jobs_members.where(job_id: current_jobs).destroy_all
    end

    # archived memberis working in projects
    def archived_project_member(member)
        member.project_members.update_all(is_archived: false)
    end
end
