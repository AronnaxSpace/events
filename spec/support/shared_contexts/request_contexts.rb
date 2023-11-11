shared_context 'logged in user' do
  before do
    create(:profile, user: user)
    sign_in user
  end

  let(:user) { create(:user) }
end

shared_context 'logged in user withot profile' do
  before do
    sign_in user
  end

  let(:user) { create(:user) }
end
