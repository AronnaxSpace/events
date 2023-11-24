describe 'Friends', type: :request do
  include_context 'logged in user'

  describe 'GET /index' do
    before { get friends_path }

    it 'gets HTTP status 200' do
      expect(response.status).to eq 200
    end
  end

  describe 'POST /create' do
    let(:friend) { create(:user) }

    before do
      friendship_reator = double('FriendshipCreator')

      allow(FriendshipCreator).to receive(:new).with(user, friend).and_return(friendship_reator)
      allow(friendship_reator).to receive(:call).and_return(result)

      post friends_path, params: { friend_id: friend.id }
    end

    context 'when result is successful' do
      let(:result) { double('Result', success?: true) }

      it 'redirects to friends_path with a success message' do
        expect(response).to redirect_to friends_path
        expect(flash[:notice]).to eq 'Friendship request was successfully sent'
      end
    end

    context 'when result is not successful' do
      let(:result) { double('Result', success?: false, error: 'something went wrong') }

      it 'redirects to friends_path with an error message' do
        expect(response).to redirect_to friends_path
        expect(flash[:alert]).to eq 'something went wrong'
      end
    end
  end

  describe 'DELETE /destroy' do
    let(:friendship) { create(:friendship, user: user) }

    before { delete friend_path(friendship) }

    it 'redirects to friends_path with a success message' do
      expect(response).to redirect_to friends_path
      expect(flash[:notice]).to eq 'Friendship request was successfully deleted'
    end
  end

  describe 'PATCH /accept' do
    subject { patch accept_friend_path(friendship) }

    let(:friendship) { create(:friendship, :pending, friend: user) }

    it 'accepts the friendship request' do
      expect { subject }.to change { friendship.reload.aasm_state }.from('pending').to('accepted')
    end

    it 'redirects to friends_path with a success message' do
      subject

      expect(response).to redirect_to friends_path
      expect(flash[:notice]).to eq 'Friendship request was successfully accepted'
    end
  end

  describe 'PATCH /reject' do
    subject { patch reject_friend_path(friendship) }

    let(:friendship) { create(:friendship, :pending, friend: user) }

    it 'rejects the friendship request' do
      expect { subject }.to change { friendship.reload.aasm_state }.from('pending').to('rejected')
    end

    it 'redirects to friends_path with a success message' do
      subject

      expect(response).to redirect_to friends_path
      expect(flash[:notice]).to eq 'Friendship request was successfully rejected'
    end
  end
end
