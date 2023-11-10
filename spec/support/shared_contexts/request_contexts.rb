shared_context 'logged in user' do
  before do
    sign_in user
  end

  let(:user) { create(:user) }
end
