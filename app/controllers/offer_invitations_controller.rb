class OfferInvitationsController < ApplicationController
  include OfferScoped

  before_action :authorize_offer, only: %i[bulk_add bulk_create]
  before_action :check_if_offer_ended, only: %i[bulk_add bulk_create]

  helper_method :users, :offer_invitations

  def bulk_add; end

  def bulk_create
    result = OfferInvitationsManager.new(offer, params[:user_ids] || []).call

    if result.success?
      offer.invite_users! if offer.details_specified?

      redirect_to offer_path(offer)
    else
      flash.now[:alert] = result.error.message
      render :bulk_add, status: :unprocessable_entity
    end
  end

  def accept
    offer_invitation.accept!

    redirect_to offer_path(offer), notice: t('.success')
  end

  def decline
    offer_invitation.decline!

    redirect_to offers_path, notice: t('.success')
  end

  private

  def authorize_offer
    authorize offer, :manage?
  end

  def check_if_offer_ended
    redirect_to offer_path(offer) if offer.ended?
  end

  def users
    @users ||= User.without(current_user).with_profile
  end

  def offer_invitations
    @offer_invitations ||= offer.offer_invitations
  end

  def offer_invitation
    @offer_invitation ||= offer.offer_invitations.find_by(user: current_user)
  end
end
