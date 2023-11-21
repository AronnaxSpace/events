describe 'Welcomes', type: :request do
  describe 'GET /index' do
    context 'when user is not signed in' do
      it 'returns http success' do
        get root_path

        expect(response).to have_http_status(:success)
      end
    end

    context 'when user is signed in' do
      include_context 'logged in user'

      it 'redirects to authenticated_oot_path' do
        get root_path

        expect(response).to redirect_to(authenticated_root_path)
      end
    end
  end

  describe 'GET /about' do
    it 'returns http success' do
      get about_path

      expect(response).to have_http_status(:success)
    end
  end
end
