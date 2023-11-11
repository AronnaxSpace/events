class Offer < ApplicationRecord
  has_rich_text :conditions

  # associations
  belongs_to :owner, class_name: 'User'
  has_many :offer_invitations, dependent: :destroy
  has_many :users, through: :offer_invitations

  # validations
  validates :what, presence: true
  validates :where, presence: true
  validate :when_start_or_when_text_must_be_present

  # scopes
  scope :for, lambda { |user|
    where(id: user.offers.ids)
      .or(where(owner: user))
  }

  def offer_time
    when_text || "#{when_start} - #{when_end}" || when_start
  end

  private

  def when_start_or_when_text_must_be_present
    return if when_start.present? || when_text.present?

    errors.add(:offer_time, :must_be_specified)
  end
end
