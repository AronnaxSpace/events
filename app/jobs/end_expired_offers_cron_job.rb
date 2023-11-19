class EndExpiredOffersCronJob < ApplicationJob
  queue_as :default

  def perform
    Offer.published.expired.find_each(&:end!)
  end
end
