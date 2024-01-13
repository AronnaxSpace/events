class AddTimeFormatToOffers < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def up
    add_column :offers, :time_format, :string, default: 'date', null: false

    Offer.unscoped.in_batches do |relation|
      relation.update_all time_format: :datetime_range_format
      sleep(0.01) # throttle
    end
  end

  def down
    remove_column :offers, :time_format, :string
  end
end
