class AddTimeZoneAndInterfaceLanguageToProfiles < ActiveRecord::Migration[7.1]
  def change
    add_column :profiles, :time_zone, :string, null: false, default: 'UTC'
    add_column :profiles, :interface_language, :string, null: false, default: 'en'
  end
end
