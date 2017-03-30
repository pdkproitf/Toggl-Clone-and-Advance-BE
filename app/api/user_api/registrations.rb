module UserApi
    class Registrations < Grape::API
        prefix :api
        version 'v1', using: :accept_version_header

        helpers RegistrationsHelper

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
                @resource = User.new(create_params)
                @resource.provider = 'email'
                @role = Role.find_or_create_by(name: 'Admin')

                if params['user']['invited_token']
                    invite = Invite.find_by_email(params['user']['email'])
                    error!(I18n.t('not_found', title: params['user']['email']), 404) unless invite
                    error!(I18n.t("expiry", title: "Invition")) if invite.expiry?
                    error!(I18n.t("user.errors.token"), 400) unless invite.authenticated?(params['user']['invited_token'])

                    @role = Role.find_or_create_by(name: 'Member')
                    @company = invite.sender.company
                else
                    error!(I18n.t('company.errors.domain_already'), 400) if Company.find_by_domain(params['user']['company_domain'])
                    @company = create_company(params['user'])
                end

                Company.transaction do
                    User.transaction do
                        @company.save!
                        save_user
                    end
                end
            end

            before do
                authenticated!
            end

            desc 'get current user inform'
            get do
                return_message(I18n.t('success'), MemberUserSerializer.new(@current_member))
            end

            desc 'update a current user'
            params do
                requires :user, type: Hash do
                    requires :first_name, type: String, desc: 'first name'
                    requires :last_name, type:String, desc: 'last name'
                    requires :image, type: String, desc: 'user avatar'
                end
            end

            put do
                @current_member.user.update_attributes!(update_params)
                return_message(I18n.t('success'))
            end
        end
    end
end
