require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { should have_many(:offer_invitations) }
    it { should have_many(:offers).through(:offer_invitations) }
    it { should have_many(:owned_offers) }
    it { should have_one(:profile) }
  end

  describe 'scopes' do
    describe '.with_profile' do
      let!(:user_with_profile) { create(:user, :with_profile) }
      let!(:user_without_profile) { create(:user) }

      it 'returns users with profile' do
        expect(described_class.with_profile).to eq([user_with_profile])
      end
    end
  end
end
