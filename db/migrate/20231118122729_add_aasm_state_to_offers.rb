class AddAasmStateToOffers < ActiveRecord::Migration[7.1]
  def change
    add_column :offers, :aasm_state, :string
  end
end
