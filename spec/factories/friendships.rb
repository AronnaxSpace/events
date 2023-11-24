FactoryBot.define do
  factory :friendship do
    user
    association :friend, factory: :user

    aasm_state { 'accepted' }
    accepted_at { Time.current }

    trait :pending do
      aasm_state { 'pending' }
    end

    trait :accepted do
      aasm_state { 'accepted' }
      accepted_at { Time.current }
    end

    trait :rejected do
      aasm_state { 'rejected' }
      rejected_at { Time.current }
    end
  end
end
