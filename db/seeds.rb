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

  next if i < 5

  User.without(user).find_each do |friend|
    FactoryBot.create(
      :friendship,
      :accepted,
      user: user,
      friend: friend
    )
  end
end

User.find_each do |user|
  5.times do
    event = FactoryBot.create(
      :event,
      :with_conditions,
      owner: user
    )

    User.without(user).find_each do |invitee|
      invitation_state = %i[pending accepted declined].sample

      FactoryBot.create(
        :event_invitation,
        invitation_state,
        event: event,
        user: invitee
      )
    end
  end
end
