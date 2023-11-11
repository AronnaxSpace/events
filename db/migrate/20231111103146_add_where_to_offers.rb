class AddWhereToOffers < ActiveRecord::Migration[7.1]
  def change
    add_column :offers, :where, :string
  end
end
