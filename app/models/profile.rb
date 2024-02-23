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
  with_options if: -> { avatar.attached? } do
    validate :avatar_fits_allowed_size
    validate :avatar_has_corrent_format
  end

  # callbacks
  before_save :remove_avatar_if_requested

  attr_accessor :remove_avatar

  has_one_attached :avatar do |attachable|
    attachable.variant :thumb, resize_to_limit: [100, 100]
    attachable.variant :medium, resize_to_limit: [300, 300]
  end

  private

  def nickname_cannot_contain_spaces
    return if nickname.present? && !nickname.match(/\s/)

    errors.add(:nickname, :cannot_contain_spaces)
  end

  def avatar_fits_allowed_size
    return if avatar.blob.byte_size <= 10.megabytes

    avatar.purge
    errors.add(:avatar, :file_too_big)
  end

  def avatar_has_corrent_format
    return if avatar.blob.content_type.start_with? 'image/'

    avatar.purge
    errors.add(:avatar, :invalid_format)
  end

  def remove_avatar_if_requested
    avatar.purge if remove_avatar == '1'
  end
end
