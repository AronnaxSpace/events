class RemoveConditionsFromOffers < ActiveRecord::Migration[7.1]
  def change
    remove_column :offers, :conditions, :string
  end
end
