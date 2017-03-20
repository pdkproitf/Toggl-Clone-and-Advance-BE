module UserApi
    class Registrations < Grape::API
        prefix :api
        version 'v1', using: :accept_version_header
        #
        helpers do
            def sign_up_params
                user_params = params['user']
                User.new(
                        first_name: user_params['first_name'],
                        last_name: user_params['last_name'],
                        email: user_params['email'],
                        password: user_params['password'],
                        password_confirmation: user_params['password_confirmation']
                )
            end

            def create_company param_company
                Company.new(name: param_company['company_domain'], domain: param_company['company_domain'].slice(0,20))
            end

            def create_member
                @company.members.build(user_id: @resource.id, role_id: @role.id)
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
                        redirect_url: @redirect_url)
                    end
                    @member = create_member
                    Member.transaction do
                        @member.save!
                        create_default_job
                    end

                    return_message I18n.t('success'), UserSerializer.new(@resource)
                end
            end

            def create_default_job
                @member.jobs_members.create!(job_id: Job.find_or_create_by(name: 'President'))  if params['company_domain']
                @member.jobs_members.create!(job_id: Job.find_or_create_by(name: 'Developper'))  if params['invited_token']
            end
        end

        resource :users do
            # => /api/v1/users/
            desc 'create new user' # , entity: Entities::ProductWithRoot
            params do
                requires :user, type: Hash do
                    requires :first_name, type: String, desc: 'First Name'
                    requires :last_name, type: String, desc: 'Last Name'
                    requires :email, type: String, desc: "User's Email"
                    requires :password, type: String, desc: 'password'
                    requires :password_confirmation, type: String, desc: 'password_confirmation'
                    optional :company_domain, type: String, desc: 'Company Name'
                    optional :invited_token, type: String, desc: "invited Token Of company"
                    exactly_one_of :company_domain, :invited_token
                end
            end
            post '/' do
                @resource = sign_up_params
                @resource.provider = 'email'
                @redirect_url = 'https://spring-time-tracker.herokuapp.com/'
                @role = Role.find_by_name('Admin') || Role.create!(name: 'Admin')

                if params['user']['invited_token']
                    invite = Invite.find_by_email(params['user']['email'])
                    error!(I18n.t('not_found', title: params['user']['email']), 404) unless invite
                    error!(I18n.t("expiry", title: "Invition")) if invite.expiry?
                    error!(I18n.t("user.errors.token"), 400) unless invite.authenticated?(params['user']['invited_token'])

                    @role = Role.find_by_name('Member') || Role.create!(name: 'Member')
                    @company = invite.sender.company
                else
                    error!(I18n.t('company.errors.domain_already'), 400) if Company.find_by_domain(params['user']['company_domain'])
                    @company = create_company params['user']
                end

                Company.transaction do
                    User.transaction do
                        @company.save!
                        save_user
                    end
                end
            end
        end
    end
end
