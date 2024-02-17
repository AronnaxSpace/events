class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable,
         :rememberable, :validatable, :confirmable

  # associations
  has_many :owned_events,
           class_name: 'Event',
           foreign_key: :owner_id,
           inverse_of: :owner,
           dependent: :destroy
  has_many :event_invitations, dependent: :destroy
  has_many :events, through: :event_invitations
  has_one :profile, dependent: :destroy
  has_many :outgoing_friendships, class_name: 'Friendship', foreign_key: :user_id, dependent: :destroy
  has_many :incoming_friendships, class_name: 'Friendship', foreign_key: :friend_id, dependent: :destroy

  # scopes
  scope :with_profile, -> { joins(:profile).where.not(profile: { id: nil }) }

  delegate :name, :nickname, :time_zone, :interface_language, to: :profile

  def friends
    User.where(id: Friendship.accepted_for(self).pluck(:user_id, :friend_id).flatten.uniq - [id])
  end
end
