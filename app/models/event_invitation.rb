class EventInvitation < ApplicationRecord
  include AASM

  # associations
  belongs_to :event
  belongs_to :user

  # validations
  validates :user, uniqueness: { scope: :event_id, message: :already_invited }
  validate :user_cannot_be_owner, on: :create

  # callbacks
  before_create :send_invitation, if: -> { draft? && event.published? }

  # scopes
  scope :for, ->(user) { where(user: user) }
  scope :pending_or_accepted, -> { where(aasm_state: %i[pending accepted]) }

  aasm timestamps: true do
    state :draft, initial: true
    state :pending
    state :accepted
    state :declined
    state :expired

    event :send_invitation, after_commit: :send_invitation_email do
      transitions from: :draft, to: :pending, guard: :event_published?
    end

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

  def user_cannot_be_owner
    return unless event && user
    return unless event.owner == user

    errors.add(:user, :cannot_be_owner)
  end

  def send_invitation_email
    EventMailer.with(event_invitation: self).new_event.deliver_later
  end

  def event_published?
    event.published?
  end
end
