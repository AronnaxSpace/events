describe OfferPolicy do
  subject { described_class }

  let(:offerer) { create(:user) }
  let(:offer) { build(:offer, offerer: offerer) }

  permissions :manage?, :destroy? do
    it 'denies access if user is not an offerer' do
      expect(subject).not_to permit(create(:user), offer)
    end

    it 'grants access if user is an offerer' do
      expect(subject).to permit(offerer, offer)
    end
  end

  permissions :edit?, :update? do
    context 'when the offer is not ended' do
      let(:offer) { build(:offer, :published, offerer: offerer) }

      it 'denies access if user is not an offerer' do
        expect(subject).not_to permit(create(:user), offer)
      end

      it 'grants access if user is an offerer' do
        expect(subject).to permit(offerer, offer)
      end
    end

    context 'when the offer is ended' do
      let(:offer) { build(:offer, :ended, offerer: offerer) }

      it 'denies access' do
        expect(subject).not_to permit(create(:user), offer)
      end
    end
  end
end
