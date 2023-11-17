class OfferInvitationsController < ApplicationController
  helper_method :users, :offer

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

  private

  def users
    @users ||= User.without(current_user).with_profile
  end

  def offer
    @offer ||= current_user.owned_offers.find_by!(uuid: params[:offer_id])
  end
end
