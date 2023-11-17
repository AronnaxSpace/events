class OffersController < ApplicationController
  helper_method :offer

  def index
    @offers = Offer.for(current_user)
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
    @offer = current_user.owned_offers.new(offer_params)

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
    @offer ||= Offer.for(current_user).find(params[:id])
  end

  def offer_params
    params.require(:offer).permit(
      :what, :where, :when_start, :when_end, :when_text, :conditions
    )
  end
end
