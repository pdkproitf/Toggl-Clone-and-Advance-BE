class CompanySerializer < ActiveModel::Serializer
    attributes :id, :name, :domain, :working_time_per_day, :working_time_per_week,
        :begin_week, :clients, :incre_dayoff, :year_dayoffs
    has_many :clients, serializer: ClientSerializer
end
