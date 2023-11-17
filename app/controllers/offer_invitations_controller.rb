class OfferInvitationsController < ApplicationController
  include OfferScoped

  before_action :authorize_offer, only: %i[bulk_add bulk_create]

  helper_method :users

  def bulk_add
    redirect_to offer_path(offer) if offer.users_invited?
  end

  def bulk_create
    result = InvitationsBulkCreator.new(offer, params[:user_ids]).call

    if result.success?
      redirect_to offer_path(offer), notice: t('.success')
    else
      @error = result.error.message
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

  def users
    @users ||= User.without(current_user).with_profile
  end

  def offer_invitation
    @offer_invitation ||= offer.offer_invitations.find_by(user: current_user)
  end
end
