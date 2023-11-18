class OfferInvitationsManager
  def initialize(offer, user_ids)
    @offer = offer
    @user_ids = user_ids
  end

  def call
    raise(StandardError.new, I18n.t('offer_invitations.bulk_create.no_users_selected')) if users.empty?

    users.each do |user|
      OfferInvitation.create(offer: @offer, user: user)
    end

    @offer.invite_users! if @offer.details_specified?

    OpenStruct.new(success?: true)
  rescue StandardError => e
    OpenStruct.new(success?: false, error: e)
  end

  private

  def users
    @users ||= User.where(id: @user_ids)
  end
end
