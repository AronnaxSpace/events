describe FriendshipCreator do
  subject { described_class.new(user, friend).call }

  let(:user) { create(:user) }
  let(:friend) { create(:user) }

  context 'when counter friendship exists' do
    context 'when counter friendship is pending' do
      let!(:counter_friendship) { create(:friendship, :pending, user: friend, friend: user) }

      it 'accepts counter friendship' do
        expect { subject }.to change { counter_friendship.reload.aasm_state }
                          .from('pending').to('accepted')
      end

      it 'returns success' do
        expect(subject.success?).to eq true
      end
    end

    context 'when counter friendship is not pending' do
      let!(:counter_friendship) { create(:friendship, :accepted, user: friend, friend: user) }

      it 'returns error' do
        expect(subject.success?).to eq false
        expect(subject.error).to eq 'Friendship already exists'
      end
    end
  end

  context 'when counter friendship does not exist' do
    context 'when friendship is valid' do
      it 'creates friendship' do
        expect { subject }.to change { Friendship.count }.by(1)
      end

      it 'returns success' do
        expect(subject.success?).to eq true
      end
    end

    context 'when friendship is not valid' do
      before do
        allow_any_instance_of(Friendship).to receive(:save!).and_raise(StandardError, 'Error')
      end

      it 'returns error' do
        expect(subject.success?).to eq false
        expect(subject.error).to eq 'Error'
      end
    end

    context 'when friendship already exists' do
      before do
        create(:friendship, user: user, friend: friend)
      end

      it 'returns error' do
        expect(subject.success?).to eq false
        expect(subject.error).to include 'Friendship request already exists'
      end
    end
  end
end
