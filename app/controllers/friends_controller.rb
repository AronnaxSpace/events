class FriendsController < ApplicationController
  before_action :authorize_friendship, only: %i[destroy accept reject]

  helper_method :friendship

  def index
    @friends = case params[:scope]
               when 'incoming'
                 current_user.incoming_friends
               when 'outgoing'
                 current_user.outgoing_friends
               else
                 current_user.friends
               end
  end

  def create
    result = FriendshipCreator.new(current_user, User.find(params[:friend_id])).call

    if result.success?
      redirect_to friends_path, notice: t('.success')
    else
      redirect_to friends_path, alert: result.error
    end
  end

  def destroy
    friendship.destroy

    redirect_to friends_path, notice: t('.success')
  end

  def accept
    friendship.accept!

    redirect_to friends_path, notice: t('.success')
  end

  def reject
    friendship.reject!

    redirect_to friends_path, notice: t('.success')
  end

  private

  def authorize_friendship
    authorize friendship
  end

  def friendship
    @friendship ||= Friendship.find(params[:id])
  end
end
