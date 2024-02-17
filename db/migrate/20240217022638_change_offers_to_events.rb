class ChangeOffersToEvents < ActiveRecord::Migration[7.1]
  def change
    rename_table :offers, :events
    rename_column :events, :offerer_id, :owner_id
    rename_table :offer_invitations, :event_invitations
    rename_column :event_invitations, :offer_id, :event_id
  end
end
