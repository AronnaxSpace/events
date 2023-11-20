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

  # scopes
  scope :with_profile, -> { joins(:profile).where.not(profile: { id: nil }) }

  delegate :name, :nickname, :time_zone, :interface_language, to: :profile
end
