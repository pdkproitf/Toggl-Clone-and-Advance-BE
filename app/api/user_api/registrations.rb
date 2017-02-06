module UserApi
  class Registrations < Grape::API
    prefix :api
    version 'v1', using: :accept_version_header
    #
    helpers do
      def sign_up_params
        user_params = params['user']
        user = User.new(
        first_name: user_params['first_name'],
        last_name: user_params['last_name'],
        email: user_params['email'],
        password: user_params['password'],
        password_confirmation: user_params['password_confirmation']
        )
        user
      end

      def return_message status, data = nil
        {
          status: status,
          data: data
        }
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
        end
      end
      post '/' do
        @resource = sign_up_params
        @resource.provider = 'email'
        @redirect_url = 'https://spring-time-tracker.herokuapp.com/'
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
          return return_message 'Success', @resource
        end
      end
    end
  end
end
