require 'rails_helper'

RSpec.describe OfferInvitation, type: :model do
  describe 'associations' do
    it { should belong_to(:offer) }
    it { should belong_to(:user) }
  end

  describe 'scopes' do
    describe '.for' do
      let(:user) { create(:user) }
      let(:offer) { create(:offer) }
      let!(:offer_invitation) { create(:offer_invitation, user: user, offer: offer) }

      before { create(:offer_invitation, offer: offer) }

      it 'returns offer invitation for user' do
        expect(described_class.for(user)).to eq([offer_invitation])
      end
    end

    describe '.pending_or_accepted' do
      let!(:pending_offer_invitation) { create(:offer_invitation, :pending) }
      let!(:accepted_offer_invitation) { create(:offer_invitation, :accepted) }
      let!(:declined_offer_invitation) { create(:offer_invitation, :declined) }

      it 'returns offer invitation for user' do
        expect(described_class.pending_or_accepted).to eq([pending_offer_invitation, accepted_offer_invitation])
      end
    end
  end
end
