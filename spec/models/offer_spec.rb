require 'rails_helper'

RSpec.describe Offer, type: :model do
  describe 'associations' do
    it { should belong_to(:offerer) }
    it { should have_many(:offer_invitations) }
    it { should have_many(:users).through(:offer_invitations) }
  end

  describe 'validations' do
    it { should validate_presence_of(:what) }
    it { should validate_presence_of(:where) }

    describe 'when_start or when_text cannot both be nil' do
      let(:offer) { build(:offer, when_start: nil, when_text: nil) }

      it 'is not valid' do
        expect(offer).to_not be_valid
        expect(offer.errors[:offer_time]).to include('must be specified')
      end
    end
  end

  describe 'scopes' do
    describe '.for' do
      subject { described_class.for(user) }

      let(:user) { create(:user) }
      let!(:offer_created_by_user) { create(:offer, offerer: user) }
      let!(:offer_with_invitation) { create(:offer) }
      let!(:offer_without_invitation) { create(:offer) }

      before { create(:offer_invitation, offer: offer_with_invitation, user: user) }

      it 'returns offers for a given user' do
        expect(subject).to include(offer_created_by_user, offer_with_invitation)
        expect(subject).not_to include(offer_without_invitation)
      end
    end
  end

  describe '#offer_time' do
    subject { offer.offer_time }

    let(:offer) { build(:offer) }

    context 'when when_text is present' do
      before do
        offer.when_start = nil
        offer.when_end = nil
        offer.when_text = 'in a week'
      end

      it { is_expected.to eq(offer.when_text) }
    end

    context 'when when_start and when_end are present' do
      before do
        offer.when_start = '2021-01-01'
        offer.when_end = '2021-01-02'
        offer.when_text = nil
      end

      it { is_expected.to eq("#{offer.when_start} - #{offer.when_end}") }
    end

    context 'when when_start is present' do
      before do
        offer.when_start = '2021-01-01'
        offer.when_end = nil
        offer.when_text = nil
      end

      it { is_expected.to eq(offer.when_start) }
    end
  end
end
