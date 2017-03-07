class CompanySerializer < ActiveModel::Serializer
  attributes :id, :name, :domain, :overtime_max, :begin_week, :clients
  has_many :clients, serializer: ClientSerializer
end
