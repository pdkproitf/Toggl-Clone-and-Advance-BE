class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :created_at, :updated_at, :uid, :client_id, :access_token

  def client_id
    object.tokens.to_a.last.first
  end

  def access_token
    object.tokens.to_a.last.last[:token]
  end
end
