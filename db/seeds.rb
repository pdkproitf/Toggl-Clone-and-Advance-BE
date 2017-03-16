# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Role.create!(name: 'Admin')
Role.create!(name: 'PM')
Role.create!(name: 'Member')

Company.create!(name: 'CES Australia', domain: 'code-engine')
Company.create!(name: 'Axon', domain: 'axon.active')
Company.create!(name: 'Framja', domain: 'framja')
#
Job.find_or_create_by(name: 'President')
Job.find_or_create_by(name: 'Developer')
Job.find_or_create_by(name: 'Design')
Job.find_or_create_by(name: 'Marketting')
