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
  validates :start_on, presence: true, if: -> { date? || date_range? }
  validates :end_on, presence: true, if: -> { date_range? }
  validates :start_at, presence: true, if: -> { date_and_time? || date_and_time_range? }
  validates :end_at, presence: true, if: -> { date_and_time_range? }
  validate :start_cannot_be_in_the_past, if: :start_changed?
  validate :end_cannot_be_earlier_than_start, if: :start_or_end_changed?

  # callbacks
  # before_validation :time_fields_cleanup, if: :time_format_changed?

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
    if date? || date_range?
      return if start_on.blank?
      return if start_on >= Date.current

      errors.add(:start_on, :cannot_be_in_the_past)
    elsif date_and_time? || date_and_time_range?
      return if start_at.blank?
      return if start_at >= Time.current

      errors.add(:start_at, :cannot_be_in_the_past)
    end
  end

  def end_cannot_be_earlier_than_start
    if date_range?
      return if start_on.blank? || end_on.blank?
      return if end_on >= start_on

      errors.add(:end_on, :cannot_be_earlier_than_start)
    elsif date_and_time_range?
      return if start_at.blank? || end_at.blank?
      return if end_at > start_at

      errors.add(:end_at, :cannot_be_earlier_than_start)
    end
  end

  def start_changed?
    start_on_changed? || start_at_changed?
  end

  def start_or_end_changed?
    start_changed? || end_on_changed? || end_at_changed?
  end

  def send_invitations
    offer_invitations.draft.each(&:send_invitation!)
  end

  def expire_invitations
    offer_invitations.pending.each(&:expire!)
  end
end
