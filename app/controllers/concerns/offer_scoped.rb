module OfferScoped
  extend ActiveSupport::Concern

  included do
    helper_method :offer
  end

  private

  def offer
    @offer ||= Offer.for(current_user).find_by!(uuid: params[:offer_id])
  end
end
