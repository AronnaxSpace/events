describe OfferInvitation, type: :model do
  describe 'associations' do
    it { should belong_to(:offer) }
    it { should belong_to(:user) }
  end

  describe 'validations' do
    subject { build(:offer_invitation) }

    it { should validate_uniqueness_of(:user).scoped_to(:offer_id).with_message(:already_invited) }

    describe 'cannot_invite_offerer' do
      let(:offer) { create(:offer) }
      let(:user) { offer.offerer }
      let(:offer_invitation) { build(:offer_invitation, offer: offer, user: user) }

      it 'is not valid' do
        expect(offer_invitation).not_to be_valid
        expect(offer_invitation.errors[:user]).to include("can't be the same as offerer")
      end
    end
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
