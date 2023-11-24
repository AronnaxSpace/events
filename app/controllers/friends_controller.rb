class FriendsController < ApplicationController
  before_action :authorize_friendship, only: %i[destroy accept reject]

  helper_method :friendship

  def index
    @friends = case params[:scope]
               when 'incoming'
                 User.with_profile
                     .joins(:outgoing_friendships)
                     .where(friendships: { aasm_state: 'pending', friend: current_user })
               when 'outgoing'
                 User.with_profile
                     .joins(:incoming_friendships)
                     .where(friendships: { aasm_state: 'pending', user: current_user })
               else
                 current_user.friends
               end
  end

  def create
    result = FriendshipCreator.new(current_user, User.find(params[:friend_id])).call

    if result.success?
      redirect_back fallback_location: friends_path, notice: t('.success')
    else
      redirect_back fallback_location: friends_path, alert: result.error
    end
  end

  def destroy
    friendship.destroy

    redirect_back fallback_location: friends_path, notice: t('.success')
  end

  def accept
    friendship.accept!

    redirect_back fallback_location: friends_path, notice: t('.success')
  end

  def reject
    friendship.reject!

    redirect_back fallback_location: friends_path, notice: t('.success')
  end

  private

  def authorize_friendship
    authorize friendship
  end

  def friendship
    @friendship ||= Friendship.find(params[:id])
  end
end
