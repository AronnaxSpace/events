class RemoveUsersInvitedFromOffers < ActiveRecord::Migration[7.1]
  def change
    remove_column :offers, :users_invited, :boolean, default: false
  end
end
