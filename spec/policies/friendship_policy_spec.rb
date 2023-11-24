describe FriendshipPolicy do
  subject { described_class }

  let(:user) { create(:user) }

  permissions :destroy? do
    it 'grants access if user is friendship user' do
      expect(subject).to permit(user, build(:friendship, user: user))
    end

    it 'grants access if user is friendship friend' do
      expect(subject).to permit(user, build(:friendship, friend: user))
    end

    it 'denies access if user is not friendship user or friend' do
      expect(subject).not_to permit(user, build(:friendship))
    end
  end

  permissions :accept?, :reject? do
    it 'grants access if user is friendship friend' do
      expect(subject).to permit(user, build(:friendship, friend: user))
    end

    it 'denies access if user is not friendship friend' do
      expect(subject).not_to permit(user, build(:friendship))
    end
  end
end
