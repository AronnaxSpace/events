class AddAasmStateToOfferInvitations < ActiveRecord::Migration[7.1]
  def change
    add_column :offer_invitations, :aasm_state, :string
    add_column :offer_invitations, :accepted_at, :datetime
    add_column :offer_invitations, :declined_at, :datetime
    add_column :offer_invitations, :expired_at, :datetime
  end
end
