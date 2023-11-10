class CreateOffers < ActiveRecord::Migration[7.1]
  def change
    create_table :offers do |t|
      t.string :what
      t.datetime :when_start
      t.datetime :when_end
      t.string :when_text
      t.text :conditions

      t.timestamps
    end
  end
end
