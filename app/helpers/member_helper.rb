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
            company_jobs = member.company.company_jobs.find_or_create_by!(job_id: id)
            company_jobs.jobs_members.find_or_create_by!(member_id: member.id)
        end
    end

    # => find job was removed in front end and removed it
    def job_removed(current_jobs, new_jobs, member)
        current_jobs.reject{|x| new_jobs.include? x.id}

        company_jobs = member.company.company_jobs.where(job_id: current_jobs)
        company_jobs.each{|company_job| company_job.jobs_members.where(member_id: member.id).destroy_all}
    end

    # archived memberis working in projects
    def archived_project_member(member)
        member.project_members.update_all(is_archived: false)
    end
end
