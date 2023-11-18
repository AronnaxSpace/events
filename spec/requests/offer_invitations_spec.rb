describe 'OfferInvitations', type: :request do
  include_context 'logged in user'

  describe 'GET /bulk_add' do
    before { get offer_bulk_add_invitations_path(offer) }

    context 'when offer has no invited users' do
      let(:offer) { create(:offer, offerer: user, users_invited: false) }

      it 'gets HTTP status 200' do
        expect(response.status).to eq 200
      end
    end

    context 'when offer has invited users' do
      let(:offer) { create(:offer, offerer: user, users_invited: true) }

      it 'redirects to the offer' do
        expect(response).to redirect_to(offer_path(offer))
      end
    end
  end

  describe 'POST /bulk_create' do
    let(:offer) { create(:offer, offerer: user) }
    let(:result) { double(:result, success?: success, error: double(:error, message: 'error message')) }

    before do
      allow_any_instance_of(InvitationsBulkCreator).to receive(:call).and_return(result)

      post offer_bulk_create_invitations_path(offer)
    end

    context 'when bulk create is successful' do
      let(:success) { true }

      it 'redirects to the offer' do
        expect(response).to redirect_to(offer_path(offer))
      end
    end

    context 'when bulk create is not successful' do
      let(:success) { false }

      it 'receives the error' do
        expect(response.status).to eq 422
        expect(response.body).to include('error message')
      end
    end
  end

  describe 'POST /accept' do
    let(:offer) { create(:offer) }
    let!(:offer_invitation) { create(:offer_invitation, offer: offer, user: user) }

    before { post accept_offer_invitation_path(offer) }

    it 'accepts the invitation' do
      expect(offer_invitation.reload.accepted?).to be true
    end

    it 'redirects to the offer' do
      expect(response).to redirect_to(offer_path(offer))
    end
  end

  describe 'POST /decline' do
    let(:offer) { create(:offer) }
    let!(:offer_invitation) { create(:offer_invitation, offer: offer, user: user) }

    before { post decline_offer_invitation_path(offer) }

    it 'declines the invitation' do
      expect(offer_invitation.reload.declined?).to be true
    end

    it 'redirects to offers list' do
      expect(response).to redirect_to(offers_path)
    end
  end
end
