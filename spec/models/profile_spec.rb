describe Profile, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:nickname) }
    it { should validate_length_of(:name).is_at_least(3).is_at_most(50) }
    it { should validate_length_of(:nickname).is_at_least(3).is_at_most(20) }

    describe 'uniqueness of nickname' do
      subject { create(:profile) }

      it { should validate_uniqueness_of(:nickname).case_insensitive }
    end

    describe 'nickname cannot contain spaces' do
      let(:profile) { build(:profile, nickname: 'with spaces') }

      it 'is invalid if contains spaces' do
        expect(profile).to be_invalid
        expect(profile.errors[:nickname]).to include('cannot contain spaces')
      end
    end
  end
end
