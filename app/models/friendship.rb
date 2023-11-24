class Friendship < ApplicationRecord
  include AASM

  # associations
  belongs_to :user
  belongs_to :friend, class_name: 'User'

  # validations
  validate :friend_cannot_be_self
  validate :friendship_uniqueness, on: :create

  # scopes
  scope :accepted_for, ->(user) { accepted.where('user_id = ? OR friend_id = ?', user.id, user.id) }

  # state machine
  aasm timestamps: true do
    state :pending, initial: true
    state :accepted
    state :rejected

    event :accept do
      transitions from: :pending, to: :accepted
    end

    event :reject do
      transitions from: :pending, to: :rejected
    end
  end

  private

  def friend_cannot_be_self
    return unless user && friend
    return unless user == friend

    errors.add(:friend, :cannot_be_self) if user == friend
  end

  def friendship_uniqueness
    return unless user && friend
    return unless Friendship.exists?(user: user, friend: friend) ||
                  Friendship.exists?(user: friend, friend: user)

    errors.add(:base, :already_exists)
  end
end
