FactoryBot.define do
  factory :user do
    username { Faker::Internet.unique.username(specifier: 3..20, separators: %w[_]) }
    email { Faker::Internet.unique.email }
    password { "password123" }
    password_confirmation { "password123" }
  end
end
