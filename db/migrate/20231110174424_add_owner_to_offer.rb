class AddOwnerToOffer < ActiveRecord::Migration[7.1]
  def change
    add_reference :offers, :owner, null: false, foreign_key: { to_table: :users }
  end
end
