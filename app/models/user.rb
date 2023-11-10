class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :rememberable, :validatable

  # associations
  has_many :owned_offers,
           class_name: 'Offer',
           foreign_key: :owner_id,
           inverse_of: :owner,
           dependent: :destroy
  has_many :offer_invitations, dependent: :destroy
  has_many :offers, through: :offer_invitations
end
