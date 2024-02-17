describe 'Events', type: :request do
  include_context 'logged in user'

  let!(:event) { create(:event, title: 'evented by user', owner: user) }

  describe 'GET /index' do
    let(:another_owner) { create(:user, :with_profile) }
    let(:event_without_invitation_for_user) { create(:event, title: 'user not invited', owner: another_owner) }
    let(:event_with_pending_invitation_for_user) { create(:event, title: 'pending for user', owner: another_owner) }
    let(:event_with_accepted_invitation_for_user) do
      create(:event, title: 'accepted by user', owner: another_owner)
    end
    let(:event_with_declined_invitation_for_user) do
      create(:event, title: 'declined by user', owner: another_owner)
    end

    before do
      event_without_invitation_for_user
      create(:event_invitation, :pending, event: event_with_pending_invitation_for_user, user: user)
      create(:event_invitation, :accepted, event: event_with_accepted_invitation_for_user, user: user)
      create(:event_invitation, :declined, event: event_with_declined_invitation_for_user, user: user)

      get events_path
    end

    it 'gets HTTP status 200' do
      expect(response.status).to eq 200
    end

    it "receives events' data" do
      expect(response.body).to include(
        event.title,
        event_with_pending_invitation_for_user.title,
        event_with_accepted_invitation_for_user.title
      )

      expect(response.body).not_to include(
        event_without_invitation_for_user.title,
        event_with_declined_invitation_for_user.title
      )
    end
  end

  describe 'GET /show' do
    before { get event_path(event) }

    it 'gets HTTP status 200' do
      expect(response.status).to eq 200
    end

    it "receives event's data" do
      expect(response.body).to include(event.title)
    end
  end

  describe 'GET /new' do
    before { get new_event_path }

    it 'gets HTTP status 200' do
      expect(response.status).to eq 200
    end
  end

  describe 'GET /edit' do
    before { get edit_event_path(event) }

    it 'gets HTTP status 200' do
      expect(response.status).to eq 200
    end
  end

  describe 'POST /create' do
    subject { post events_path, params: { event: attributes_for(:event, :details_specified) } }

    it 'creates a new event' do
      expect { subject }.to change(Event, :count).by(1)
    end

    it 'redirects to bulk_add_invitations page' do
      subject
      expect(response).to redirect_to(event_bulk_add_invitations_path(Event.last))
    end
  end

  describe 'PATCH /update' do
    let(:params) { { event: attributes_for(:event, :with_conditions) } }

    before { patch event_path(event), params: params }

    it 'updates the event' do
      event.reload

      %i[title place start_at end_at].each do |attribute|
        expect(event.public_send(attribute)).to eq params[:event][attribute]
      end
      expect(event.conditions.to_plain_text).to eq params[:event][:conditions]
    end

    it 'redirects to the event' do
      expect(response).to redirect_to(event_path(event))
    end
  end

  describe 'DELETE /destroy' do
    subject { delete event_path(event) }

    it 'deletes the event' do
      expect { subject }.to change(Event, :count).by(-1)
    end

    it 'redirects to the events list' do
      subject
      expect(response).to redirect_to(events_path)
    end
  end

  describe 'POST /publish' do
    subject { post publish_event_path(event) }

    let!(:event) { create(:event, :users_invited, owner: user) }

    context 'when the event is valid' do
      it 'publishes the event' do
        expect { subject }.to change { event.reload.published? }.from(false).to(true)
      end

      it 'redirects to the event' do
        subject
        expect(response).to redirect_to(event_path(event))
      end
    end

    context 'when the event is not valid' do
      before { event.update_attribute(:title, nil) }

      it 'does not publish the event' do
        expect { subject }.not_to(change { event.reload.published? })
      end

      it 'redirects to the edit event page' do
        subject
        expect(response).to redirect_to(edit_event_path(event))
      end

      it 'shows an alert' do
        subject
        event.save
        expect(flash[:alert]).to eq event.errors.full_messages.join(', ')
      end
    end
  end
end
