class Offer < ApplicationRecord
  has_rich_text :conditions

  # associations
  belongs_to :offerer, class_name: 'User'
  has_many :offer_invitations, dependent: :destroy
  has_many :users, through: :offer_invitations

  # validations
  validates :what, presence: true
  validates :where, presence: true
  validate :when_start_or_when_text_must_be_present

  # scopes
  scope :for, lambda { |user|
    where(id: user.offers.ids)
      .or(where(offerer: user))
  }

  def to_param
    uuid
  end

  def offer_time
    return when_text if when_text.present?
    return "#{when_start} - #{when_end}" if when_start.present? && when_end.present?

    when_start
  end

  private

  def when_start_or_when_text_must_be_present
    return if when_start.present? || when_text.present?

    errors.add(:offer_time, :must_be_specified)
  end
end
