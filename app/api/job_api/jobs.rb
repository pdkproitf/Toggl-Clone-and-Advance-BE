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

            desc 'create new job'
            params do
                requires :job, type: Hash do
                    requires :name, type: String, desc: 'job title'
                end
            end
            post do
                job = @current_member.company.jobs.find_by_name(params[:job][:name])
                error!(I18n.t('already', content: params[:job][:name]), 409) if job

                job = Job.find_or_create_by!(name: params[:job][:name])
                @current_member.company.jobs_members.create!(job_id: job.id)

                return_message(I18n.t('success'), JobSerializer.new(job))
            end
        end
    end
end
