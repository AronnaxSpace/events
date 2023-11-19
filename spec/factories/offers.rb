FactoryBot.define do
  factory :offer do
    association :offerer, factory: :user

    what { Faker::Hipster.sentence }
    where { Faker::Address.full_address }
    start_at { Faker::Date.forward(days: 23).to_datetime }
    end_at { Faker::Date.between(from: start_at + 1.day, to: start_at + 1.month).to_datetime }
    aasm_state { :published }

    trait :with_conditions do
      conditions { Faker::Hipster.paragraph }
    end

    trait :details_specified do
      aasm_state { :details_specified }
    end

    trait :users_invited do
      aasm_state { :users_invited }
    end

    trait :published do
      aasm_state { :published }
    end

    trait :ended do
      aasm_state { :ended }
    end

    trait :expired do
      start_at { 25.days.ago.to_datetime }

      after(:build) do |offer|
        offer.end_at = Faker::Date.backward(days: 23).to_datetime
        offer.save(validate: false)
      end
    end
  end
end
