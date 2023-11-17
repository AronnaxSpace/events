class RenameOwnerToOffererInOffers < ActiveRecord::Migration[7.1]
  def change
    rename_column :offers, :owner_id, :offerer_id
  end
end
