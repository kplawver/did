FactoryBot.define do
  factory :entry do
    user
    body { Faker::Lorem.paragraph }
    tag { :did }
    posted_on { Date.current }
  end
end
