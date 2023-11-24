module OffersHelper
  def offer_time_for(offer)
    "#{offer.start_at} - #{offer.end_at}"
  end

  def offer_state_tag_classes_for(offer)
    return 'tag-warning' if offer.draft?
    return 'tag-secondary' if offer.archived?

    'tag-success'
  end
end
