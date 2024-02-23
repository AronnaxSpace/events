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

    describe 'avatar validations' do
      let(:profile) { create(:profile) }

      context 'when avatar has incorrect format' do
        before do
          profile.avatar.attach(
            io: File.open('spec/support/fixtures/test_file.txt'),
            filename: 'test_file.txt',
            content_type: 'text/plain'
          )
        end

        it 'adds an error for the avatar' do
          expect(profile.errors[:avatar]).to include('must be an image.')
        end
      end
    end
  end

  describe 'callbacks' do
    let(:profile) { create(:profile) }

    context 'when remove_avatar is set to "1"' do
      before do
        profile.avatar.attach(
          io: File.open('spec/support/fixtures/test_image.jpg'),
          filename: 'test_image.jpg',
          content_type: 'image/jpg'
        )
        profile.remove_avatar = '1'
        profile.save
      end

      it 'removes the avatar' do
        expect(profile.avatar).not_to be_attached
      end
    end
  end
end
