# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

client = Client.create!(
    name: 'Empty client'
)

project = Project.create!(
    name: 'Empty project',
    client_id: client.id,
    background: '',
    report_permission: 2
)

category = Category.create!(
    name: 'Empty category',
    default: false
)

project_category = ProjectCategory.create!(
    project_id: project.id,
    category_id: category.id,
    billable: false
)

user = User.create!(
    name: 'empty',
    email: 'empty@gmail.com',
    password: '123456',
    password_confirmation: '123456'
)

project_category = ProjectCategoryUser.create!(
    project_category_id: project_category.id,
    user_id: user.id
)

# project_category = ProjectCategoryUser.create!(
#     project_category_id: project_category.id,
#     user_id: user.id
# )
