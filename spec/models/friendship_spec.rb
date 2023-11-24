describe Friendship, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:friend).class_name('User') }
  end

  describe 'validations' do
    subject { build(:friendship) }

    it 'validates that user is not the same as friend' do
      subject.friend = subject.user
      expect(subject).not_to be_valid
      expect(subject.errors[:friend]).to include("can't be yourself")
    end

    it 'validates that friendship is unique' do
      create(:friendship, user: subject.user, friend: subject.friend)
      expect(subject).not_to be_valid
      expect(subject.errors[:base]).to include('Friendship request already exists')
    end
  end

  describe 'scopes' do
    describe '.accepted_for' do
      subject { described_class.accepted_for(user) }

      let(:user) { create(:user) }
      let(:friendships) do
        [
          create(:friendship, :accepted, user: user),
          create(:friendship, :accepted, friend: user)
        ]
      end
      let!(:another_friendship) { create(:friendship, :accepted) }

      it { should match_array(friendships) }
    end
  end
end
