FactoryBot.define do
  factory :event do
    association :owner, factory: :user

    title { Faker::Hipster.sentence }
    place { Faker::Address.full_address }
    start_at { Faker::Date.forward(days: 10).to_datetime }
    end_at { Faker::Date.between(from: 11.days.from_now, to: 30.days.from_now).to_datetime }
    aasm_state { :published }
    time_format { :datetime_range_format }

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

    trait :archived do
      aasm_state { :archived }
    end
  end
end
