describe 'Profiles', type: :request do
  include_context 'logged in user withot profile'

  let(:profile) { user.profile }

  describe 'GET /new' do
    before { get new_profile_path }

    it 'gets HTTP status 200' do
      expect(response.status).to eq 200
    end
  end

  describe 'GET /edit' do
    include_context 'logged in user'

    before { get edit_profile_path(profile) }

    it 'gets HTTP status 200' do
      expect(response.status).to eq 200
    end
  end

  describe 'POST /create' do
    subject { post profile_path, params: { profile: attributes_for(:profile) } }

    it 'creates a new profile for the user' do
      expect { subject }.to change(Profile, :count).by(1)
      expect(Profile.last).to eq user.profile
    end
  end

  describe 'PATCH /update' do
    include_context 'logged in user'

    let(:params) { { profile: attributes_for(:profile) } }

    before { patch profile_path(profile), params: params }

    it "updates the user's profile" do
      expect(profile.reload).to have_attributes(params[:profile])
    end
  end
end
