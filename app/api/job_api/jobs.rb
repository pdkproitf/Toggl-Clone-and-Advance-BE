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

            desc 'get all jobs'
            get '/' do
                return_message(I18n.t("success"), Job.all.map {|e| JobSerializer.new(e)})
            end

            desc 'create new job'
            params do
                requires :job, type: Hash do
                    requires :name, type: String, desc: 'job title'
                end
            end
            post do
                job = Job.create!(name: params[:job][:name])
                return_message(I18n.t('success'), JobSerializer.new(job))
            end
        end
    end
end
