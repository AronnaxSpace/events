class FriendshipCreator
  def initialize(user, friend)
    @user = user
    @friend = friend
  end

  def call
    counter_friendship = Friendship.find_by(user: @friend, friend: @user)

    if counter_friendship.present?
      raise(StandardError, 'Friendship already exists') unless counter_friendship.pending?

      counter_friendship.accept!
      return success
    end

    @user.outgoing_friendships.create!(friend: @friend)
    success
  rescue StandardError => e
    OpenStruct.new(success?: false, error: e.message)
  end

  private

  def success
    OpenStruct.new(success?: true)
  end
end
