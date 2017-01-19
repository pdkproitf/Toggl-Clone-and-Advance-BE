module UserApi
  class Registrations < Grape::API
    prefix  :api
    version 'v1', using: :accept_version_header
    #
    helpers do
      def sign_up_params
        user_params = params['user']
        user = User.new(
                  name: user_params['name'],
                  email: user_params['email'],
                  password: user_params['password'],
                  password_confirmation: user_params['password_confirmation'])
        return user
      end

      def render_create_success
        {
          status: 'success',
          data:   @resource
        }
      end

      def render_create_error
        {
          status: 'error',
          data:    @resource,
          errors: '',
          code: 422
        }
      end
    end

    resource :users do
      # => /api/v1/users/
      desc "create new user" #, entity: Entities::ProductWithRoot
      params do
        requires :user, type: Hash do
          requires :name, type: String, desc: "User Name"
          requires :email, type: String, desc: "User's Email"
          requires :password,  type: String, desc: "password"
          requires :password_confirmation,  type: String, desc: "password_confirmation"
        end
      end
      post '/' do
        @resource = sign_up_params
        # binding.pry
        @resource.provider   = "email"
        @redirect_url = 'http://localhost:3000/'
        if @resource.save!
          unless @resource.confirmed?
            # user will require email authentication
            @resource.send_confirmation_instructions({
              client_config: params[:config_name],
              redirect_url: @redirect_url
              })
          else
            # email auth has been bypassed, authenticate user
            @client_id = SecureRandom.urlsafe_base64(nil, false)
            @token     = SecureRandom.urlsafe_base64(nil, false)

            @resource.tokens[@client_id] = {
              token: BCrypt::Password.create(@token),
              expiry: (Time.now + DeviseTokenAuth.token_lifespan).to_i
            }

            @resource.save!
          end
          return render_create_success
        end
      end
    end
  end
end
