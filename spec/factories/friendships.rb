FactoryBot.define do
  factory :friendship do
    user
    association :friend, factory: :user

    aasm_state { 'accepted' }

    trait :pending do
      aasm_state { 'pending' }
    end

    trait :accepted do
      aasm_state { 'accepted' }
    end

    trait :rejected do
      aasm_state { 'rejected' }
    end
  end
end
