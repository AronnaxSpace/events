describe Offer, type: :model do
  describe 'associations' do
    it { should belong_to(:offerer) }
    it { should have_many(:offer_invitations) }
    it { should have_many(:users).through(:offer_invitations) }
  end

  describe 'validations' do
    it { should validate_presence_of(:what) }
    it { should validate_presence_of(:where) }
    it { should validate_presence_of(:start_at) }
    it { should validate_presence_of(:end_at) }

    describe 'end_at_must_be_in_the_future' do
      subject { build(:offer, :published, start_at: 2.days.ago, end_at: end_at) }

      context 'when end_at is in the future' do
        let(:end_at) { 1.day.from_now }

        it { should be_valid }
      end

      context 'when end_at is in the past' do
        let(:end_at) { 1.day.ago }

        context 'when the offer is not ended' do
          it { should_not be_valid }
        end

        context 'when the offer is ended' do
          subject { build(:offer, :ended, start_at: 2.days.ago, end_at: end_at) }

          it { should be_valid }
        end
      end
    end

    describe 'end_at_must_be_after_start_at' do
      subject { build(:offer, start_at: start_at, end_at: end_at) }

      context 'when end_at is before start_at' do
        let(:start_at) { 2.days.from_now }
        let(:end_at) { 1.day.from_now }

        it { should_not be_valid }
      end

      context 'when end_at is after start_at' do
        let(:start_at) { 1.day.from_now }
        let(:end_at) { 2.days.from_now }

        it { should be_valid }
      end
    end
  end

  describe 'scopes' do
    describe '.for' do
      subject { described_class.for(user) }

      let(:user) { create(:user) }
      let!(:offer_created_by_user) { create(:offer, offerer: user) }
      let(:offer_with_pending_invitation) { create(:offer) }
      let(:offer_with_accepted_invitation) { create(:offer) }
      let(:offer_with_declined_invitation) { create(:offer) }
      let!(:offer_without_invitation) { create(:offer) }

      before do
        create(:offer_invitation, :pending, offer: offer_with_pending_invitation, user: user)
        create(:offer_invitation, :accepted, offer: offer_with_accepted_invitation, user: user)
        create(:offer_invitation, :declined, offer: offer_with_declined_invitation, user: user)
      end

      it 'returns offers for a given user' do
        expect(subject).to include(
          offer_created_by_user,
          offer_with_pending_invitation,
          offer_with_accepted_invitation
        )
        expect(subject).not_to include(offer_without_invitation)
        expect(subject).not_to include(offer_with_declined_invitation)
      end
    end

    describe '.expired' do
      subject { described_class.expired }

      let(:expired_offer) { build(:offer, :published, start_at: 2.days.ago, end_at: 1.day.ago) }
      let(:ended_offer) { build(:offer, :ended, start_at: 2.days.ago, end_at: 1.day.ago) }
      let(:users_invited_offer) { build(:offer, :users_invited, start_at: 2.days.ago, end_at: 1.day.ago) }
      let!(:active_offer) { build(:offer, start_at: 1.day.from_now, end_at: 2.days.from_now) }

      before do
        expired_offer.save(validate: false)
        expired_offer.save(validate: false)
        users_invited_offer.save(validate: false)
      end

      it 'returns published offers with end_at in the past' do
        expect(subject).to include(expired_offer)
        expect(subject).not_to include(ended_offer, users_invited_offer, active_offer)
      end
    end
  end

  describe 'aasm_state transitions' do
    describe '#invite_users' do
      subject { offer.invite_users }

      let(:offer) { create(:offer, :details_specified) }

      it 'transitions to users_invited' do
        expect { subject }.to change { offer.aasm_state }.from('details_specified').to('users_invited')
      end
    end

    describe '#publish' do
      subject { offer.publish! }

      let(:offer) { create(:offer, :users_invited) }

      before { create_list(:offer_invitation, 3, :draft, offer: offer) }

      it 'transitions to publish' do
        expect { subject }.to change { offer.reload.aasm_state }
                          .from('users_invited').to('published')
      end

      it 'sends invitations' do
        expect { subject }.to change { offer.reload.offer_invitations.pluck(:aasm_state).uniq }
                          .from(%w[draft]).to(%w[pending])
      end
    end

    describe '#end' do
      subject { offer.end! }

      let(:offer) { create(:offer, :published) }

      before { create_list(:offer_invitation, 3, :pending, offer: offer) }

      it 'transitions to ended' do
        expect { subject }.to change { offer.reload.aasm_state }
                          .from('published').to('ended')
      end

      it 'expires pending invitations' do
        expect { subject }.to change { offer.reload.offer_invitations.pluck(:aasm_state).uniq }
                          .from(%w[pending]).to(%w[expired])
      end
    end
  end

  describe '#publised_or_ended?' do
    subject { offer.published_or_ended? }

    context 'when offer is published' do
      let(:offer) { build(:offer, :published) }

      it { should be_truthy }
    end

    context 'when offer is ended' do
      let(:offer) { build(:offer, :ended) }

      it { should be_truthy }
    end

    context 'when offer is not published nor ended' do
      let(:offer) { build(:offer, :details_specified) }

      it { should be_falsey }
    end
  end
end
