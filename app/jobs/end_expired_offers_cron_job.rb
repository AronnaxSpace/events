class EndExpiredOffersCronJob < ApplicationJob
  queue_as :default

  def perform
    Offer.expired.find_each(&:end!)
  end
end
