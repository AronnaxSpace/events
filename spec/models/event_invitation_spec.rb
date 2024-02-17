describe EventInvitation, type: :model do
  describe 'associations' do
    it { should belong_to(:event) }
    it { should belong_to(:user) }
  end

  describe 'validations' do
    subject { build(:event_invitation) }

    it { should validate_uniqueness_of(:user).scoped_to(:event_id).with_message(:already_invited) }

    describe 'cannot_invite_owner' do
      let(:event) { create(:event) }
      let(:user) { event.owner }
      let(:event_invitation) { build(:event_invitation, event: event, user: user) }

      it 'is not valid' do
        expect(event_invitation).not_to be_valid
        expect(event_invitation.errors[:user]).to include("can't be the same as owner")
      end
    end
  end

  describe 'callbacks' do
    describe 'send_invitation' do
      let(:event_invitation) { build(:event_invitation, :draft, event: event) }

      context 'when event is not published' do
        let(:event) { create(:event, :users_invited) }

        it 'does not send invitation' do
          expect(event_invitation).not_to receive(:send_invitation)
          event_invitation.save
        end
      end

      context 'when event is published' do
        let(:event) { create(:event, :published) }

        it 'sends invitation' do
          expect(event_invitation).to receive(:send_invitation)
          event_invitation.save
        end
      end
    end
  end

  describe 'scopes' do
    describe '.for' do
      let(:user) { create(:user) }
      let(:event) { create(:event) }
      let!(:event_invitation) { create(:event_invitation, user: user, event: event) }

      before { create(:event_invitation, event: event) }

      it 'returns event invitation for user' do
        expect(described_class.for(user)).to eq([event_invitation])
      end
    end

    describe '.pending_or_accepted' do
      let!(:pending_event_invitation) { create(:event_invitation, :pending) }
      let!(:accepted_event_invitation) { create(:event_invitation, :accepted) }
      let!(:declined_event_invitation) { create(:event_invitation, :declined) }

      it 'returns event invitation for user' do
        expect(described_class.pending_or_accepted).to eq([pending_event_invitation, accepted_event_invitation])
      end
    end
  end

  describe 'aasm_state transitions' do
    describe '#send_invitation' do
      let(:event_invitation) { create(:event_invitation, :draft, event: event) }

      subject { event_invitation.send_invitation! }

      context 'when event is not published' do
        let(:event) { create(:event, :users_invited) }

        it 'raises an error' do
          expect { subject }.to raise_error(AASM::InvalidTransition)
        end
      end

      context 'when event is published' do
        let(:event) { create(:event, :published) }

        before { event_invitation.update(aasm_state: :draft) }

        it 'sends invitation' do
          expect { subject }.to change { event_invitation.reload.aasm_state }
                            .from('draft').to('pending')
        end

        it 'sends invitation email' do
          expect(EventMailer).to receive_message_chain(:with, :new_event, :deliver_later)
          subject
        end
      end
    end
  end
end
