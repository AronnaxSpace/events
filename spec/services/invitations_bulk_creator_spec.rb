describe InvitationsBulkCreator do
  describe '#call' do
    subject { described_class.new(offer, user_ids).call }

    let(:offer) { create('offer') }

    context 'when users present' do
      let(:user_ids) { create_list('user', 3).map(&:id) }

      it 'returns successful result' do
        expect(subject.success?).to be true
      end

      it 'bulk creates offer invitations' do
        expect { subject }.to change(OfferInvitation, :count).by(3)
      end
    end

    context 'when users empty' do
      let(:user_ids) { [] }

      it 'returns not successful result with error' do
        expect(subject.success?).to be false
        expect(subject.error.message).to eq I18n.t('offer_invitations.bulk_create.no_users_selected')
      end

      it 'doest not create offer invitations' do
        expect { subject }.to change(OfferInvitation, :count).by(0)
      end
    end
  end
end
