# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Category.create!(name: 'Developement', default: true)
Category.create!(name: 'Design', default: true)
Category.create!(name: 'QA', default: true)
Category.create!(name: 'Fixbug', default: true)
Category.create!(name: 'Maintain', default: true)
Role.create!(name: 'Admin')
Role.create!(name: 'PM')
5.times do |i|
    Client.create(name: "Client #{i}")
end
