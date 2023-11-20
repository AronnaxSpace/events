# frozen_string_literal: true

(1..5).each do |i|
  email = "user_#{i}@aronnax.space"
  next if User.exists?(email: email)

  user = User.create(
    email: email,
    password: 'aRo44@X',
    confirmed_at: Time.current
  )

  FactoryBot.create(:profile, user: user)
end

User.find_each do |user|
  5.times do
    offer = FactoryBot.create(
      :offer,
      :with_conditions,
      offerer: user
    )

    User.without(user).find_each do |invitee|
      invitation_state = %i[pending accepted declined].sample

      FactoryBot.create(
        :offer_invitation,
        invitation_state,
        offer: offer,
        user: invitee
      )
    end
  end
end
