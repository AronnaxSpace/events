class AddUuidToOffers < ActiveRecord::Migration[7.1]
  def change
    enable_extension 'uuid-ossp' unless extension_enabled?('uuid-ossp')

    add_column :offers, :uuid, :uuid, null: false, default: 'uuid_generate_v4()'

    add_index :offers, :uuid, unique: true
  end
end
