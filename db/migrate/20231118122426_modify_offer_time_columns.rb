class ModifyOfferTimeColumns < ActiveRecord::Migration[7.1]
  def change
    # rename when_start and when_end to start_at and end_at
    rename_column :offers, :when_start, :start_at
    rename_column :offers, :when_end, :end_at

    # remove when_text
    remove_column :offers, :when_text, :string
  end
end
