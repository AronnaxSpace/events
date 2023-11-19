class EndExpiredOffersCronJob < ApplicationJob
  queue_as :default

  def perform
    Offer.expired.find_each(&:end_without_validation!)
  end
end
