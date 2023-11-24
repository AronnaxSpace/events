describe User, type: :model do
  describe 'associations' do
    it { should have_many(:offered_offers).class_name('Offer') }
    it { should have_many(:offer_invitations) }
    it { should have_many(:offers).through(:offer_invitations) }
    it { should have_one(:profile) }
    it { should have_many(:outgoing_friendships).class_name('Friendship').with_foreign_key(:user_id) }
    it { should have_many(:incoming_friendships).class_name('Friendship').with_foreign_key(:friend_id) }
    it { should have_many(:outgoing_friends).through(:outgoing_friendships).source(:friend) }
    it { should have_many(:incoming_friends).through(:incoming_friendships).source(:user) }

    describe '.friends' do
      let(:user) { create(:user) }

      before do
        create(:friendship, :accepted, user: user)
        create(:friendship, :accepted, friend: user)
        create(:friendship, :pending, user: user)
        create(:friendship, :rejected, user: user)
      end

      it 'returns accepted friendships' do
        expect(user.friends.count).to eq(2)
      end
    end
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
