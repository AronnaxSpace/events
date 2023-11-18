module OffersHelper
  def offer_time_for(offer)
    "#{offer.start_at} - #{offer.end_at}"
  end
end
