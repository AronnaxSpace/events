class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable,
         :rememberable, :validatable, :confirmable

  # associations
  has_many :offered_offers,
           class_name: 'Offer',
           foreign_key: :offerer_id,
           inverse_of: :offerer,
           dependent: :destroy
  has_many :offer_invitations, dependent: :destroy
  has_many :offers, through: :offer_invitations
  has_one :profile, dependent: :destroy
  has_many :outgoing_friendships, class_name: 'Friendship', foreign_key: :user_id, dependent: :destroy
  has_many :incoming_friendships, class_name: 'Friendship', foreign_key: :friend_id, dependent: :destroy
  has_many :outgoing_friends, through: :outgoing_friendships, source: :friend
  has_many :incoming_friends, through: :incoming_friendships, source: :user

  # scopes
  scope :with_profile, -> { joins(:profile).where.not(profile: { id: nil }) }

  delegate :name, :nickname, :time_zone, :interface_language, to: :profile

  def friends
    User.where(id: Friendship.accepted_for(self).pluck(:user_id, :friend_id).flatten.uniq - [id])
  end
end
