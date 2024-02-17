class Event < ApplicationRecord
  include AASM

  enum time_format: {
    date_format: 'date',
    datetime_format: 'datetime',
    date_range_format: 'date_range',
    datetime_range_format: 'datetime_range'
  }

  has_rich_text :conditions

  # associations
  belongs_to :owner, class_name: 'User'
  has_many :event_invitations, dependent: :destroy
  has_many :users, through: :event_invitations

  # validations
  validates :title, presence: true
  validates :place, presence: true
  validates :time_format, presence: true
  validates :start_at, presence: true
  validates :end_at, presence: true, if: -> { date_range_format? || datetime_range_format? }
  validate :start_cannot_be_in_the_past, if: :start_at_changed?
  validate :end_must_be_after_start

  # callbacks
  before_save :adjust_end_at, if: :start_at_changed?

  # scopes
  scope :for, lambda { |user|
    active_event_ids = user.events
                           .joins(:event_invitations)
                           .where(event_invitations: { aasm_state: %i[pending accepted] })
                           .ids

    where(id: active_event_ids)
      .or(where(owner: user))
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
    return if (date_format? || date_range_format?) && start_at.to_date >= Date.current
    return if (datetime_format? || datetime_range_format?) && start_at >= Time.current

    errors.add(:start_at, :cannot_be_in_the_past)
  end

  def end_must_be_after_start
    return unless date_range_format? || datetime_range_format?
    return if start_at.blank? || end_at.blank?
    return if date_range_format? && end_at.to_date >= start_at.to_date
    return if datetime_range_format? && end_at > start_at

    errors.add(:end_at, :must_be_after_start)
  end

  def adjust_end_at
    return if datetime_range_format?

    self.end_at = if date_range_format?
                    end_at.end_of_day
                  else
                    start_at.end_of_day
                  end

    self.end_at = start_at + 1.minute if end_at == start_at
  end

  def send_invitations
    event_invitations.draft.each(&:send_invitation!)
  end

  def expire_invitations
    event_invitations.pending.each(&:expire!)
  end
end
