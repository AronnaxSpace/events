class OfferInvitationsManager
  def initialize(offer, user_ids = [])
    @offer = offer
    @user_ids = user_ids.reject(&:blank?)
  end

  def call
    return success if @offer.offer_invitations.pluck(:user_id) == @user_ids

    @offer.offer_invitations.where.not(user_id: @user_ids).destroy_all

    users.each do |user|
      @offer.offer_invitations.find_or_create_by(user: user)
    end

    success
  rescue StandardError => e
    OpenStruct.new(success?: false, error: e)
  end

  private

  def success
    OpenStruct.new(success?: true)
  end

  def users
    @users ||= User.where(id: @user_ids)
  end
end
