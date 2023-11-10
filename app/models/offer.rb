class Offer < ApplicationRecord
  # validations
  validates :what, presence: true
  validate :when_start_or_when_text_must_be_present

  private

  def when_start_or_when_text_must_be_present
    return if when_start.present? || when_text.present?

    errors.add(:base, :date_must_be_present)
  end
end
