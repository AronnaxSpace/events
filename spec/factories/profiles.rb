FactoryBot.define do
  factory :profile do
    user

    name { Faker::Name.name }
    nickname { "#{Faker::Name.unique.neutral_first_name}_#{rand(999)}" }
  end
end
