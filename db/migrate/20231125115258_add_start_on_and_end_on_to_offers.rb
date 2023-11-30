class AddStartOnAndEndOnToOffers < ActiveRecord::Migration[7.1]
  def change
    add_column :offers, :start_on, :date
    add_column :offers, :end_on, :date
  end
end
