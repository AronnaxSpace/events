describe 'EventInvitations', type: :request do
  include_context 'logged in user'

  describe 'GET /bulk_add' do
    context 'when user is authorized to manage the event' do
      before { get event_bulk_add_invitations_path(event) }

      context 'when event is not archived' do
        let(:event) { create(:event, :details_specified, owner: user) }

        it 'gets HTTP status 200' do
          expect(response.status).to eq 200
        end
      end

      context 'when event is archived' do
        let(:event) { create(:event, :archived, owner: user) }

        it 'redirects to the event' do
          expect(response).to redirect_to(event_path(event))
        end
      end
    end

    context 'when user is not authorized to manage the event' do
      let(:event) { create(:event, :details_specified) }

      before do
        create(:event_invitation, :accepted, event: event, user: user)

        get event_bulk_add_invitations_path(event)
      end

      it 'gets HTTP status 302' do
        expect(response.status).to eq 302
        expect(flash[:alert]).to eq('You are not authorized to perform this action.')
      end
    end
  end

  describe 'POST /bulk_create' do
    let(:event) { create(:event, :details_specified, owner: user) }
    let(:result) { double(:result, success?: success, error: double(:error, message: 'error message')) }

    before do
      allow_any_instance_of(EventInvitationsManager).to receive(:call).and_return(result)

      post event_bulk_create_invitations_path(event)
    end

    context 'when bulk create is successful' do
      let(:success) { true }

      it 'redirects to the event' do
        expect(response).to redirect_to(event_path(event))
      end

      it 'makes the event state users_invited' do
        expect(event.reload.users_invited?).to be true
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
    let(:event) { create(:event) }
    let!(:event_invitation) { create(:event_invitation, event: event, user: user) }

    before { post accept_event_invitation_path(event) }

    it 'accepts the invitation' do
      expect(event_invitation.reload.accepted?).to be true
    end

    it 'redirects to the event' do
      expect(response).to redirect_to(event_path(event))
    end
  end

  describe 'POST /decline' do
    let(:event) { create(:event) }
    let!(:event_invitation) { create(:event_invitation, event: event, user: user) }

    before { post decline_event_invitation_path(event) }

    it 'declines the invitation' do
      expect(event_invitation.reload.declined?).to be true
    end

    it 'redirects to events list' do
      expect(response).to redirect_to(events_path)
    end
  end
end
