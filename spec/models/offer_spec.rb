require 'rails_helper'

RSpec.describe Offer, type: :model do
  describe 'associations' do
    it { should belong_to(:owner) }
    it { should have_many(:offer_invitations) }
    it { should have_many(:users).through(:offer_invitations) }
  end

  describe 'validations' do
    it { should validate_presence_of(:what) }

    describe 'when_start or when_text cannot both be nil' do
      let(:offer) { build(:offer, when_start: nil, when_text: nil) }

      it 'is not valid' do
        expect(offer).to_not be_valid
        expect(offer.errors[:base]).to include('Offer date must be present')
      end
    end
  end

  describe 'scopes' do
    describe '.for' do
      subject { described_class.for(user) }

      let(:user) { create(:user) }
      let!(:offer_created_by_user) { create(:offer, owner: user) }
      let!(:offer_with_invitation) { create(:offer) }
      let!(:offer_without_invitation) { create(:offer) }

      before { create(:offer_invitation, offer: offer_with_invitation, user: user) }

      it 'returns offers for a given user' do
        expect(subject).to include(offer_created_by_user, offer_with_invitation)
        expect(subject).not_to include(offer_without_invitation)
      end
    end
  end
end
