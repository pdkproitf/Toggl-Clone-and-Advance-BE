class HolidaySerializer < ActiveModel::Serializer
  attributes :id, :name, :begin_date, :end_date
end
