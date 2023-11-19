describe OfferInvitationsManager do
  describe '#call' do
    subject { described_class.new(offer, user_ids).call }

    let(:offer) { create('offer') }
    let(:invited_users) { create_list(:user, 2) }
    let(:not_invited_users) { create_list(:user, 2) }
    let(:user_ids) { [invited_users.first.id].concat(not_invited_users.pluck(:id)) }

    before do
      invited_users.each do |user|
        create(:offer_invitation, offer: offer, user: user)
      end
    end

    it 'adjusts offer invitations' do
      expect { subject }.to change { offer.offer_invitations.count }
                        .from(2).to(3)

      expect(offer.offer_invitations.pluck(:user_id)).to match_array(user_ids)
    end

    it 'returns success' do
      expect(subject.success?).to eq true
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
end
