module JobApi
    class Jobs < Grape::API
        prefix :api
        version 'v1', using: :accept_version_header

        helpers MemberHelper

        resource :jobs do
            before do
                authenticated!
                error!(I18n.t("access_denied"), 403) unless @current_member.manager?
            end

            desc 'get all jobs in company'
            get '/' do
                return_message(I18n.t("success"),
                    @current_member.company.jobs.uniq.map {|e| JobSerializer.new(e)})
            end

            desc 'create new job for company'
            params do
                requires :job, type: Hash do
                    requires :name, type: String, desc: 'job title'
                end
            end
            post do
                job = @current_member.company.jobs.find_by_name(params[:job][:name])
                error!(I18n.t('already', content: params[:job][:name]), 409) if job

                job = Job.find_or_create_by!(name: params[:job][:name])
                @current_member.company.company_jobs.find_or_create_by(job_id: job.id)

                return_message(I18n.t('success'), JobSerializer.new(job))
            end

            desc 'edit job in company'
            params do
                requires :job, type: Hash do
                    requires :name, type: String, desc: 'job title'
                end
            end
            put ':id' do # => id of job
                company_jobs = @current_member.company.company_jobs.find_by_job_id(params[:id])
                error!(I18n.t('not_found', title: "Company Job"), 404) unless company_jobs

                job = Job.find_or_create_by!(name: params[:job][:name])
                company_jobs.update_attributes(job_id: job.id)

                return_message(I18n.t('success'))
            end

            desc 'Destroy Jobs of company'
            delete ':id' do
                company_job = @current_member.company.company_jobs.find_by_job_id(params[:id])
                error!(I18n.t('not_found', title: "Company Job"), 404) unless company_job

                company_job.destroy!
                status 200
                return_message(I18n.t('success'))
            end
        end
    end
end
