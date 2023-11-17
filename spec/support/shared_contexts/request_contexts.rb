shared_context 'logged in user' do
  before do
    sign_in user
  end

  let(:user) { create(:user, :with_profile) }
end

shared_context 'logged in user withot profile' do
  before do
    sign_in user
  end

  let(:user) { create(:user) }
end
