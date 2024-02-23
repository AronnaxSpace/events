class AddUniqueIndexxForNickname < ActiveRecord::Migration[7.1]
  def change
    add_index :profiles, :nickname, unique: true
  end
end
