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
    subject { post offers_path, params: { offer: attributes_for(:offer, :details_specified) } }

    it 'creates a new offer' do
      expect { subject }.to change(Offer, :count).by(1)
    end

    it 'redirects to bulk_add_invitations page' do
      subject
      expect(response).to redirect_to(offer_bulk_add_invitations_path(Offer.last))
    end
  end

  describe 'PATCH /update' do
    let(:params) { { offer: attributes_for(:offer, :with_conditions) } }

    before { patch offer_path(offer), params: params }

    it 'updates the offer' do
      offer.reload

      %i[what where start_at end_at].each do |attribute|
        expect(offer.public_send(attribute)).to eq params[:offer][attribute]
      end
      expect(offer.conditions.to_plain_text).to eq params[:offer][:conditions]
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

  describe 'POST /publish' do
    subject { post publish_offer_path(offer) }

    let!(:offer) { create(:offer, :users_invited, offerer: user) }

    context 'when the offer is valid' do
      it 'publishes the offer' do
        expect { subject }.to change { offer.reload.published? }.from(false).to(true)
      end

      it 'redirects to the offer' do
        subject
        expect(response).to redirect_to(offer_path(offer))
      end
    end

    context 'when the offer is not valid' do
      before { offer.update_attribute(:what, nil) }

      it 'does not publish the offer' do
        expect { subject }.not_to(change { offer.reload.published? })
      end

      it 'redirects to the edit offer page' do
        subject
        expect(response).to redirect_to(edit_offer_path(offer))
      end

      it 'shows an alert' do
        subject
        offer.save
        expect(flash[:alert]).to eq offer.errors.full_messages.join(', ')
      end
    end
  end
end
