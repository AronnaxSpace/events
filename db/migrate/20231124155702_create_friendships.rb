class CreateFriendships < ActiveRecord::Migration[7.1]
  def change
    create_table :friendships do |t|
      t.belongs_to :user, null: false, foreign_key: true
      t.belongs_to :friend, null: false, foreign_key: { to_table: :users }
      t.string :aasm_state
      t.datetime :accepted_at
      t.datetime :rejected_at

      t.timestamps
    end
  end
end
