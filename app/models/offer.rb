class Offer < ApplicationRecord
  # associations
  belongs_to :owner, class_name: 'User'
  has_many :offer_invitations, dependent: :destroy
  has_many :users, through: :offer_invitations

  # validations
  validates :what, presence: true
  validate :when_start_or_when_text_must_be_present

  # scopes
  scope :for, lambda { |user|
    where(id: user.offers.ids)
      .or(where(owner: user))
  }

  private

  def when_start_or_when_text_must_be_present
    return if when_start.present? || when_text.present?

    errors.add(:base, :date_must_be_present)
  end
end
