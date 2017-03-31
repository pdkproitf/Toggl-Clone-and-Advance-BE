module RegistrationsHelper
    def create_params
        ActionController::Parameters.new(params).require(:user)
            .permit(:first_name, :last_name, :email, :password, :password_confirmation)
    end

    def create_company(param_company)
        Company.new(name: param_company['company_domain'], domain: param_company['company_domain'].slice(0,20))
    end

    def create_member
        @company.members.new(user_id: @resource.id, role_id: @role.id)
    end

    def save_user
        if @resource.save!
            if @resource.confirmed?
                # email auth has been bypassed, authenticate user
                @client_id = SecureRandom.urlsafe_base64(nil, false)
                @token = SecureRandom.urlsafe_base64(nil, false)

                @resource.tokens[@client_id] = {
                    token: BCrypt::Password.create(@token),
                    expiry: (Time.now + DeviseTokenAuth.token_lifespan).to_i
                }
                @resource.save!
            else
                # user will require email authentication
                @resource.send_confirmation_instructions(client_config: params[:config_name],
                redirect_url: Settings.front_end)
            end
            @member = create_member
            Member.transaction do
                @member.save!
                create_default_job(params[:user]['company_domain'])
            end

            return_message I18n.t('success'), UserSerializer.new(@resource)
        end
    end

    def create_default_job(company)
        job = company.blank? ? Job.find_or_create_by(name: 'Developper') : Job.find_or_create_by(name: 'President')

        @company.jobs_members.create!(job_id: job.id, member_id: @member.id)
    end

    def update_params
        ActionController::Parameters.new(params).require(:user)
            .permit(:first_name, :last_name, :image)
    end
end
