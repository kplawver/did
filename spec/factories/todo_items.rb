FactoryBot.define do
  factory :todo_item do
    user
    title { Faker::Lorem.sentence(word_count: 4) }
    due_date { Date.current }
    completed { false }
  end
end
