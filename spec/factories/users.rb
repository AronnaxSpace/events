FactoryBot.define do
  factory :user do
    email { Faker::Internet.unique.email }
    password { Faker::Internet.password }

    trait :with_profile do
      after(:create) do |user|
        create(:profile, user: user)
      end
    end
  end
end
