module ClientApi
  class Clients < Grape::API
    prefix :api
    version 'v1', using: :accept_version_header
    #
    helpers do
      def is_admin_or_pm
        @current_member.admin? || @current_member.pm? ? true : false
      end
    end

    resource :clients do
      # => /api/v1/projects/
      before do
        authenticated!
      end

      desc 'Get all clients'
      get do
        return error!(I18n.t('access_denied'), 403) unless is_admin_or_pm
        @current_member.company.clients.order('id asc')
      end

      desc 'Get a client by id'
      params do
        requires :id, type: String, desc: 'Client ID'
      end
      get ':id' do
        return error!(I18n.t('access_denied'), 403) unless is_admin_or_pm
        @current_member.company.clients.find(params[:id])
      end

      desc 'create new client'
      params do
        requires :client, type: Hash do
          requires :name, type: String, desc: 'Client name'
        end
      end
      post do
        return error!(I18n.t('access_denied'), 403) unless is_admin_or_pm
        @current_member.company.clients.create!(name: params[:client][:name])
      end

      desc 'Delete a client'
      params do
        requires :id, type: String, desc: 'Client ID'
      end
      delete ':id' do
        return error!(I18n.t('access_denied'), 403) unless is_admin_or_pm
        @current_member.company.clients.find(params[:id]).destroy!
      end
    end
  end
end
