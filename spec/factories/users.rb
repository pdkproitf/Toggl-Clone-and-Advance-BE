FactoryGirl.define do
  factory :user do
    name  {Faker::Name.name}
    email {Faker::Internet.email}
    password  "password"
    password_confirmation "password"
  end

  factory :invalid_user, parent: :user do
    name nil
  end
end
