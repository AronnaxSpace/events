class AddUsersInvitedToOffers < ActiveRecord::Migration[7.1]
  def change
    add_column :offers, :users_invited, :boolean, default: false
  end
end
