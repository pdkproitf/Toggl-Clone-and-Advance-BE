module UserApi
  class Confirmations < Grape::API
    prefix  :api
    version 'v1', using: :accept_version_header
    #
    helpers do
      def confirmations_user
        user_params = params['user']
        user = User.find_by_confirmation_token(user_params['confirmation_token'])
        user
      end

      def return_create_success
        return {
          status: 'success',
          data: sign_in_token_validation
        }
      end

      def sign_in_token_validation
        data  = @resource.token_validation_response.to_h
        data.store('client', @client_id)
        data.store('token', @token)
        data
      end

      def return_create_error messages
        {
          status: 'false',
          data:   nil,
          errors: messages
        }
      end

      def isExpiry?
        duration = (Time.now -  @resource.confirmation_sent_at)/(24*60*60)
        duration >= 7
      end
    end

    resource :users do
      # => /api/v1/users/
      desc "confirmations" #, entity: Entities::ProductWithRoot
      params do
        requires :user, type: Hash do
          requires :confirmation_token,  type: String, desc: "confirmation_token"
        end
      end
      get '/confirmation' do
        @resource = confirmations_user
        if @resource and @resource.id
          if isExpiry?
            return_create_error 'Overtime Confirmations'
          else
            # create client id
            @client_id  = SecureRandom.urlsafe_base64(nil, false)
            @token      = SecureRandom.urlsafe_base64(nil, false)
            token_hash = BCrypt::Password.create(@token)
            expiry     = (Time.now + DeviseTokenAuth.token_lifespan).to_i

            @resource.tokens[@client_id] = {
              token:  token_hash,
              expiry: expiry
            }

            @resource.save!
            return_create_success
          end
        else
            return_create_error 'Not found Confirmations'
        end
      end
    end
  end
end
