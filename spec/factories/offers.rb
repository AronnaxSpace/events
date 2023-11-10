FactoryBot.define do
  factory :offer do
    association :owner, factory: :user

    what { Faker::Hipster.sentence }
    when_start { Faker::Date.forward(days: 23) }
    conditions { Faker::Hipster.paragraph }
  end
end
