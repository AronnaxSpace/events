module FriendsHelper
  def friendship_for(user, friend)
    Friendship.where(user: user, friend: friend)
              .or(Friendship.where(user: friend, friend: user))
              .first
  end
end
