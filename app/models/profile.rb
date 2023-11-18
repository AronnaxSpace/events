class Profile < ApplicationRecord
  # associations
  belongs_to :user

  # validations
  validates :name,
            presence: true,
            length: { minimum: 3, maximum: 50 }
  validates :nickname,
            presence: true,
            uniqueness: { case_sensitive: false },
            length: { minimum: 3, maximum: 20 }
  validate :nickname_cannot_contain_spaces

  private

  def nickname_cannot_contain_spaces
    return if nickname.present? && !nickname.match(/\s/)

    errors.add(:nickname, :cannot_contain_spaces)
  end
end
