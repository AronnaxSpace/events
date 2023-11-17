require 'rails_helper'

RSpec.describe OfferPolicy do
  subject { described_class }

  let(:offerer) { create(:user) }
  let(:offer) { build(:offer, offerer: offerer) }

  permissions :update?, :edit?, :destroy? do
    it 'denies access if user is not an offerer' do
      expect(subject).not_to permit(create(:user), offer)
    end

    it 'grants access if user is an offerer' do
      expect(subject).to permit(offerer, offer)
    end
  end
end
