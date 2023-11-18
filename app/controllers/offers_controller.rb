class OffersController < ApplicationController
  before_action :authorize_offer, only: %i[edit update destroy]

  helper_method :offer, :offer_invitation

  def index
    @offers = Offer.for(current_user).order(created_at: :desc)
  end

  def show
    redirect_to offer_bulk_add_invitations_path(offer) unless offer.users_invited

    @offer_invitations = offer.offer_invitations
  end

  def new
    @offer = Offer.new
  end

  def edit; end

  def create
    @offer = current_user.offered_offers.new(offer_params)

    if @offer.save
      redirect_to offer_bulk_add_invitations_path(offer)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if offer.update(offer_params)
      redirect_to offer, notice: t('.success')
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    offer.destroy

    redirect_to offers_url, notice: t('.success')
  end

  private

  def offer
    @offer ||= Offer.for(current_user).find_by!(uuid: params[:id])
  end

  def offer_params
    params.require(:offer).permit(
      :what, :where, :when_start, :when_end, :when_text, :conditions
    )
  end

  def authorize_offer
    authorize offer, :manage?
  end

  def offer_invitation
    @offer_invitation ||= offer.offer_invitations.find_by(user: current_user)
  end
end
