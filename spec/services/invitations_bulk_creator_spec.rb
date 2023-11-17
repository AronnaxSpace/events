describe InvitationsBulkCreator do
  describe '#call' do
    subject { described_class.new(offer, user_ids).call }

    let(:offer) { create('offer') }
    let(:user_ids) { create_list('user', 3).map(&:id) }

    it 'bulk creates offer invitations' do
      expect { subject }.to change(OfferInvitation, :count).by(3)
    end
  end
end
