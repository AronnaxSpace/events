class Profile < ApplicationRecord
  # associations
  belongs_to :user

  # validations
  validates :name, presence: true
  validates :nickname, presence: true, uniqueness: { case_sensitive: false }
end
