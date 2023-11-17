require 'rails_helper'

RSpec.describe 'OfferInvitations', type: :request do
  include_context 'logged in user'

  describe 'GET /bulk_add' do
    before { get offer_bulk_add_invitations_path(offer) }

    context 'when offer has no invited users' do
      let(:offer) { create(:offer, owner: user, users_invited: false) }

      it 'gets successful response' do
        expect(response.status).to eq 200
      end
    end

    context 'when offer has invited users' do
      let(:offer) { create(:offer, owner: user, users_invited: true) }

      it 'redirects to offer path' do
        expect(response).to redirect_to(offer_path(offer))
      end
    end
  end

  describe 'POST /bulk_create' do
    let(:offer) { create(:offer, owner: user) }
    let(:result) { double(:result, success?: success, error: double(:error, message: 'error message')) }

    before do
      allow_any_instance_of(InvitationsBulkCreator).to receive(:call).and_return(result)

      post offer_bulk_create_invitations_path(offer)
    end

    context 'when bulk create is successful' do
      let(:success) { true }

      it 'redirects to offer path' do
        expect(response).to redirect_to(offer_path(offer))
      end
    end

    context 'when bulk create is not successful' do
      let(:success) { false }

      it 'displays the error' do
        expect(response.status).to eq 422
        expect(response.body).to include('error message')
      end
    end
  end
end
