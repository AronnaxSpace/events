class Offer < ApplicationRecord
  include AASM

  has_rich_text :conditions

  # associations
  belongs_to :offerer, class_name: 'User'
  has_many :offer_invitations, dependent: :destroy
  has_many :users, through: :offer_invitations

  # validations
  validates :what, presence: true
  validates :where, presence: true
  validates :start_at, presence: true
  validates :end_at, presence: true
  validate :end_at_must_be_in_the_future
  validate :end_at_must_be_after_start_at

  # scopes
  scope :for, lambda { |user|
    active_offer_ids = user.offers
                           .joins(:offer_invitations)
                           .where(offer_invitations: { aasm_state: %i[pending accepted] })
                           .ids

    where(id: active_offer_ids)
      .or(where(offerer: user))
  }
  scope :expired, -> { where('end_at <= ?', Time.current) }

  # state machine
  aasm do
    state :details_specified, initial: true
    state :users_invited
    state :published
    state :ended

    event :invite_users do
      transitions from: :details_specified, to: :users_invited
    end

    event :publish, after_commit: :send_invitations do
      transitions from: :users_invited, to: :published
    end

    event :end, after_commit: :expire_invitations do
      transitions from: :published, to: :ended
    end
  end

  def to_param
    uuid
  end

  private

  def end_at_must_be_in_the_future
    return unless changes[:end_at].present? && end_at.present?
    return if end_at > Time.current

    errors.add(:end_at, :must_be_in_the_future)
  end

  def end_at_must_be_after_start_at
    return unless end_at.present? && start_at.present?
    return if end_at > start_at

    errors.add(:end_at, :must_be_after_start_at)
  end

  def send_invitations
    offer_invitations.draft.each(&:send_invitation!)
  end

  def expire_invitations
    offer_invitations.pending.each(&:expire!)
  end
end
