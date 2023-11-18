FactoryBot.define do
  factory :offer_invitation do
    offer
    user

    aasm_state { :pending }

    trait :draft do
      aasm_state { :draft }
    end

    trait :pending do
      aasm_state { :pending }
    end

    trait :accepted do
      aasm_state { :accepted }
    end

    trait :declined do
      aasm_state { :declined }
    end
  end
end
