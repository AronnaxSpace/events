class OfferInvitation < ApplicationRecord
  # associations
  belongs_to :offer
  belongs_to :user
end
