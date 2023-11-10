class OffersController < ApplicationController
  def index
    @offers = Offer.for(current_user)
  end
end
