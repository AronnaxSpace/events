FactoryBot.define do
  factory :offer do
    association :owner, factory: :user

    what { Faker::Hipster.sentence }
    where { Faker::Address.full_address }
    when_start { Faker::Date.forward(days: 23) }
    users_invited { true }

    trait :with_conditions do
      conditions { Faker::Hipster.paragraph }
    end
  end
end
