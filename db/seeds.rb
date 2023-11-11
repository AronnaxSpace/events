# frozen_string_literal: true

(1..3).each do |i|
  email = "user_#{i}@aronnax.space"
  next if User.exists?(email: email)

  User.create(
    email: email,
    password: 'aRo44@X'
  )
end

User.find_each do |user|
  5.times do
    FactoryBot.create(
      :offer,
      :with_conditions,
      owner: user
    )
  end
end
