module UserApi
  class Sessions < Grape::API
    prefix  :api
    version 'v1', using: :accept_version_header
    #
    helpers do
      def sign_in_params
        user_params = params['user']
        User.find_by(email: user_params['email'])
      end

      def return_create_success
        binding.pry
        {
          status: 'success',
          data: @resource.token_validation_response
        }
      end

      def render_create_error_not_confirmed
        {
          success: false,
          errors: [ I18n.t("devise_token_auth.sessions.not_confirmed", email: @resource.email) ],
          status: 401
        }
      end

      def render_create_error_bad_credentials
        {
          errors: [I18n.t("devise_token_auth.sessions.bad_credentials")],
          status: 401
        }
      end
    end

    resource :users do
      # => /api/v1/users/
      desc "sign-in" #, entity: Entities::ProductWithRoot
      params do
        requires :user, type: Hash do
          requires :email, type: String, desc: "User's Email"
          requires :password,  type: String, desc: "password"
        end
      end
      post '/sign-in' do
        @resource = sign_in_params
        if @resource and @resource.valid_password?(params['user']['password']) and (!@resource.respond_to?(:active_for_authentication?) or @resource.active_for_authentication?)
          # create client id
          @client_id = SecureRandom.urlsafe_base64(nil, false)
          @token     = SecureRandom.urlsafe_base64(nil, false)

          @resource.tokens[@client_id] = {
            token: BCrypt::Password.create(@token),
            expiry: (Time.now + DeviseTokenAuth.token_lifespan).to_i
          }
          @resource.save
          return_create_success
        elsif @resource and not (!@resource.respond_to?(:active_for_authentication?) or @resource.active_for_authentication?)
          render_create_error_not_confirmed
        else
        render_create_error_bad_credentials
        end
      end

      desc "sign-out" #, entity: Entities::ProductWithRoot
      params do
        requires :user, type: Hash do
          requires :email, type: String, desc: "User's Email"
          requires :password,  type: String, desc: "password"
        end
      end
      delete '/sign-out' do

      end
    end
  end
end
