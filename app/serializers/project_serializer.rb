class ProjectSerializer < ActiveModel::Serializer
    include Rails.application.routes.url_helpers

    attributes :id, :name, :background, :report_permission, :archived
    has_one :client
    has_many :project_user_roles

    ## Using serializer from app/serializers/profile_serializer.rb
    # has_one :profile
    # # Using serializer using serializer described below:
    # # UserSerializer::TeamSerializer
    # has_many :teams
    #
    # def links
    #   {
    #     self: user_path(object.id),
    #     api: api_v1_user_path(id: object.id, format: :json)
    #   }
    # end
    #
    # def current_team_id
    #   object.teams&.first&.id
    # end
    #
    # class TeamSerializer < ActiveModel::Serializer
    #   attributes :id, :name, :image_url, :user_id
    #
    #   # Using serializer using serializer described below:
    #   # UserSerializer::TeamSerializer::GameSerializer
    #   has_many :games
    #
    #   class GameSerializer < ActiveModel::Serializer
    #     attributes :id, :kind, :address, :date_at
    #
    #     # Using serializer from app/serializers/gamers_serializer.rb
    #     has_many :gamers
    #   end
    # end
end
