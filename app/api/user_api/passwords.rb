module UserApi
  class Passwords < Grape::API
    prefix  :api
    version 'v1', using: :accept_version_header
    #
    helpers do
      def return_message status, data = nil
        {
          status: status,
          data: data
        }
      end

      def get_user_confirmation_token
        confirmation_token = request.headers["Confirmation-Token"]
        confirmation_token = params["user"]["confirmation_token"] unless confirmation_token
        @resource = User.find_by_confirmation_token(confirmation_token)
      end

      def resource_update_method
        if DeviseTokenAuth.check_current_password_before_update == false or @resource.allow_password_change == true
          "update_attributes"
        else
          "update_with_password"
        end
      end
    end

    resource :users do
      # => /api/v1/users/
      desc "forgot password" #, entity: Entities::ProductWithRoot
      params do
        requires :user, type: Hash do
          requires :email,  type: String, desc: "confirmation_token"
          requires :redirect_url,  type: String, desc: "redirect_url"
        end
      end
      post '/password' do
        unless params[:user][:email]
          return error!(I18n.t("devise_token_auth.passwords.missing_email"), 401)
        end

        # give redirect value from params priority
        @redirect_url = params[:user][:redirect_url]

        # fall back to default value if provided
        @redirect_url ||= DeviseTokenAuth.default_password_reset_url

        unless @redirect_url
          return error!(I18n.t("devise_token_auth.passwords.missing_redirect_url"), 401)
        end

        @email = params[:user][:email].downcase

        @resource = User.find_by_email(@email)

        unless @resource
          return return_message 'Not found!'
        end

        @resource.save!
        if @resource
          @resource.send_reset_password_instructions({
            email: @email,
            provider: 'email',
            redirect_url: @redirect_url,
            client_config: params[:config_name]
            })

            if @resource.errors.empty?
              return return_message I18n.t("devise_token_auth.passwords.sended", email: @email), {confirmation_token: @resource.confirmation_token}
            else
              @errors = @resource.errors
            end
          else
            return error!(I18n.t("devise_token_auth.passwords.user_not_found", email: @email), 404)
          end
        end

        desc "forgot password"
        params do
          requires :user, type: Hash do
            optional :confirmation_token,  type: String, desc: "confirmation_token"
            requires :password,  type: String, desc: "password"
            requires :password_confirmation,  type: String, desc: "password_confirmation"
          end
        end
        put '/password' do
          get_user_confirmation_token
          binding.pry
          unless @resource
            return return_message 'Unauthorized'
          end

          # make sure account doesn't use oauth2 provider
          unless @resource.provider == 'email'
            return return_message I18n.t("devise_token_auth.passwords.password_not_required", provider: @resource.provider.humanize)
          end

          if @resource.send(resource_update_method, params["user"])
            @resource.allow_password_change = false

            @resource.save!
            return return_message I18n.t("devise_token_auth.passwords.successfully_updated")
          else
            return @resource.errors.to_hash.merge(full_messages: @resource.errors.full_messages)
          end
        end
      end
    end
  end
