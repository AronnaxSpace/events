FactoryBot.define do
  factory :offer do
    association :owner, factory: :user

    what { Faker::Hipster.sentence }
    where { Faker::Address.full_address }
    when_start { Faker::Date.forward(days: 23) }
  end
end
