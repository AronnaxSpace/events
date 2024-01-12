class Offer < ApplicationRecord
  include AASM

  enum time_format: {
    date: 'date',
    date_and_time: 'date_and_time',
    date_range: 'date_range',
    date_and_time_range: 'date_and_time_range'
  }

  has_rich_text :conditions

  # associations
  belongs_to :offerer, class_name: 'User'
  has_many :offer_invitations, dependent: :destroy
  has_many :users, through: :offer_invitations

  # validations
  validates :title, presence: true
  validates :place, presence: true
  validates :time_format, presence: true
  validates :start_at, presence: true
  validates :end_at, presence: true, if: -> { date_range? || date_and_time_range? }
  validate :start_cannot_be_in_the_past, if: :start_at_changed?
  validate :end_must_be_later_than_start, if: :time_changed?

  # scopes
  scope :for, lambda { |user|
    active_offer_ids = user.offers
                           .joins(:offer_invitations)
                           .where(offer_invitations: { aasm_state: %i[pending accepted] })
                           .ids

    where(id: active_offer_ids)
      .or(where(offerer: user))
  }
  scope :expired, -> { published.where('end_at <= ?', Time.current) }

  # state machine
  aasm do
    state :details_specified, initial: true
    state :users_invited
    state :published
    state :archived

    event :invite_users do
      transitions from: :details_specified, to: :users_invited
    end

    event :publish, after_commit: :send_invitations do
      transitions from: :users_invited, to: :published
    end

    event :archive, after_commit: :expire_invitations do
      transitions from: :published, to: :archived
    end
  end

  def to_param
    uuid
  end

  def draft?
    details_specified? || users_invited?
  end

  def published_or_archived?
    published? || archived?
  end

  def expired?
    end_at <= Time.current
  end

  def expired_or_archived?
    expired? || archived?
  end

  private

  def start_cannot_be_in_the_past
    return if start_at.blank?
    return if (date? || date_range?) && start_at.to_date >= Date.current
    return if (date_and_time? || date_and_time_range?) && start_at >= Time.current

    errors.add(:start_at, :cannot_be_in_the_past)
  end

  def end_must_be_later_than_start
    return unless date_range? || date_and_time_range?
    return if start_at.blank? || end_at.blank?
    return if date_range? && end_at.to_date >= start_at.to_date
    return if date_and_time_range? && end_at > start_at

    errors.add(:end_at, :must_be_later_than_start)
  end

  def time_changed?
    start_at_changed? || end_at_changed?
  end

  def send_invitations
    offer_invitations.draft.each(&:send_invitation!)
  end

  def expire_invitations
    offer_invitations.pending.each(&:expire!)
  end
end
