module Authenticate
  class UserApi < Grape::API
    prefix  :api
    version 'v1', using: :accept_version_header
    #
    helpers do
      def sign_up_params
        user_params = params['user']
        user = User.new(name: user_params['name'],
                        email: user_params['email'],
                        password: user_params['password'],
                        password_confirmation: user_params['password_confirmation'])
        return user
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
        @client_id = SecureRandom.urlsafe_base64(nil, false)
            @token     = SecureRandom.urlsafe_base64(nil, false)

            @resource.tokens[@client_id] = {
              token: BCrypt::Password.create(@token),
              expiry: (Time.now + DeviseTokenAuth.token_lifespan).to_i
            }

        @resource.save!
        render @resource, serializer: UserSerializer
      end
    end
  end
end
