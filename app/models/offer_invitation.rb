class OfferInvitation < ApplicationRecord
  include AASM

  # associations
  belongs_to :offer
  belongs_to :user

  # validations
  validates :user_id, uniqueness: { scope: :offer_id, message: :already_invited }
  validate :cannot_invite_offerer, on: :create

  # scopes
  scope :for, ->(user) { where(user: user) }
  scope :pending_or_accepted, -> { where(aasm_state: %i[pending accepted]) }

  aasm timestamps: true do
    state :pending, initial: true
    state :accepted
    state :declined
    state :expired

    event :accept do
      transitions from: :pending, to: :accepted
    end

    event :decline do
      transitions from: :pending, to: :declined
    end

    event :expire do
      transitions from: :pending, to: :expired
    end
  end

  private

  def cannot_invite_offerer
    return unless offer && user
    return unless offer.offerer == user

    errors.add(:user, :cannot_be_offerer)
  end
end
