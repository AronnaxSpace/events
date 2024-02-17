describe EventInvitationsManager do
  subject { described_class.new(event, user_ids).call }

  let(:event) { create('event') }
  let(:invited_users) { create_list(:user, 2) }
  let(:not_invited_users) { create_list(:user, 2) }
  let(:user_ids) { [invited_users.first.id].concat(not_invited_users.pluck(:id)) }

  before do
    invited_users.each do |user|
      create(:event_invitation, event: event, user: user)
    end
  end

  context 'when user_ids is not empty' do
    it 'adjusts event invitations' do
      expect { subject }.to change { event.event_invitations.count }
                        .from(2).to(3)

      expect(event.event_invitations.pluck(:user_id)).to match_array(user_ids)
    end

    it 'returns success' do
      expect(subject.success?).to eq true
    end
  end

  context 'when user_ids is empty' do
    let(:user_ids) { [] }

    it 'destroys all event invitations' do
      expect { subject }.to change { event.event_invitations.count }.from(2).to(0)
    end
  end

  context 'when error occurs' do
    before do
      allow_any_instance_of(described_class).to receive(:users).and_raise(StandardError)
    end

    it 'returns error' do
      expect(subject.success?).to eq false
      expect(subject.error).to be_a(StandardError)
    end
  end
end
