class CreateOfferInvitations < ActiveRecord::Migration[7.1]
  def change
    create_table :offer_invitations do |t|
      t.belongs_to :offer, null: false, foreign_key: true
      t.belongs_to :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
