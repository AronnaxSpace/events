describe 'Offers', type: :request do
  include_context 'logged in user'

  let!(:offer) { create(:offer, what: 'offered by user', offerer: user) }

  describe 'GET /index' do
    let(:another_offerer) { create(:user, :with_profile) }
    let(:offer_without_invitation_for_user) { create(:offer, what: 'user not invited', offerer: another_offerer) }
    let(:offer_with_pending_invitation_for_user) { create(:offer, what: 'pending for user', offerer: another_offerer) }
    let(:offer_with_accepted_invitation_for_user) { create(:offer, what: 'accepted by user', offerer: another_offerer) }
    let(:offer_with_declined_invitation_for_user) { create(:offer, what: 'declined by user', offerer: another_offerer) }

    before do
      offer_without_invitation_for_user
      create(:offer_invitation, :pending, offer: offer_with_pending_invitation_for_user, user: user)
      create(:offer_invitation, :accepted, offer: offer_with_accepted_invitation_for_user, user: user)
      create(:offer_invitation, :declined, offer: offer_with_declined_invitation_for_user, user: user)

      get offers_path
    end

    it 'gets HTTP status 200' do
      expect(response.status).to eq 200
    end

    it "receives offers' data" do
      expect(response.body).to include(
        offer.what,
        offer_with_pending_invitation_for_user.what,
        offer_with_accepted_invitation_for_user.what
      )

      expect(response.body).not_to include(
        offer_without_invitation_for_user.what,
        offer_with_declined_invitation_for_user.what
      )
    end
  end

  describe 'GET /show' do
    before { get offer_path(offer) }

    it 'gets HTTP status 200' do
      expect(response.status).to eq 200
    end

    it "receives offer's data" do
      expect(response.body).to include(offer.what)
    end
  end

  describe 'GET /new' do
    before { get new_offer_path }

    it 'gets HTTP status 200' do
      expect(response.status).to eq 200
    end
  end

  describe 'GET /edit' do
    before { get edit_offer_path(offer) }

    it 'gets HTTP status 200' do
      expect(response.status).to eq 200
    end
  end

  describe 'POST /create' do
    subject { post offers_path, params: { offer: attributes_for(:offer, :users_not_invited) } }

    it 'creates a new offer' do
      expect { subject }.to change(Offer, :count).by(1)
    end

    it 'redirects to bulk_add_invitations page' do
      subject
      expect(response).to redirect_to(offer_bulk_add_invitations_path(Offer.last))
    end
  end

  describe 'PATCH /update' do
    let(:params) { { offer: attributes_for(:offer) } }

    before { patch offer_path(offer), params: params }

    it 'updates the offer' do
      expect(offer.reload).to have_attributes(params[:offer])
    end

    it 'redirects to the offer' do
      expect(response).to redirect_to(offer_path(offer))
    end
  end

  describe 'DELETE /destroy' do
    subject { delete offer_path(offer) }

    it 'deletes the offer' do
      expect { subject }.to change(Offer, :count).by(-1)
    end

    it 'redirects to the offers list' do
      subject
      expect(response).to redirect_to(offers_path)
    end
  end
end
