module Authenticate
  class SessionApi < Grape::API
    prefix  :api
    version 'v1', using: :accept_version_header
    #
    helpers do
      def sign_in
        user_params = params['user']
        User.find_by(email: user_params['email'])
      end

      def authenticate? user
        user_params = params['user']
        user.valid_password?(user_params['password'])
      end
    end

    resource :session do
      # => /api/v1/users/
      desc "sign in user" #, entity: Entities::ProductWithRoot
      params do
        requires :user, type: Hash do
          requires :email, type: String, desc: "User's Email"
          requires :password,  type: String, desc: "password"
        end
      end
      post '/sign_in' do
        @resource = sign_in
        if @resource && authenticate?(@resource)
          @client_id = SecureRandom.urlsafe_base64(nil, false)
              @token     = SecureRandom.urlsafe_base64(nil, false)

              @resource.tokens[@client_id] = {
                token: BCrypt::Password.create(@token),
                expiry: (Time.now + DeviseTokenAuth.token_lifespan).to_i
              }

          @resource.save!
        else
          return { status: 'invalid email or password' }
        end
        render @resource, serializer: UserSerializer
      end

      desc "sign out user" #, entity: Entities::ProductWithRoot
      params do
        requires :user, type: Hash do
          requires :uid, type: String, desc: "User's uid"
          requires :client,  type: String, desc: "client"
          requires :access_token,  type: String, desc: "access-token"
        end
      end

      delete '/sign_out' do
        binding.pry
        @resource = sign_in
        if @resource && authenticate?(@resource)
          @client_id = SecureRandom.urlsafe_base64(nil, false)
              @token     = SecureRandom.urlsafe_base64(nil, false)

              @resource.tokens[@client_id] = {
                token: BCrypt::Password.create(@token),
                expiry: (Time.now + DeviseTokenAuth.token_lifespan).to_i
              }

          @resource.save!
        else
          return { status: 'invalid email or password' }
        end
        render @resource, serializer: UserSerializer
      end
    end
  end
end
