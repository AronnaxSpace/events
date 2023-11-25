class RenameOfferColumns < ActiveRecord::Migration[7.1]
  def change
    rename_column :offers, :what, :title
    rename_column :offers, :where, :place
  end
end
