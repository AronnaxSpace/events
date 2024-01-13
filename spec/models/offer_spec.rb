shared_examples 'offer end_at validation' do
  context 'when end_at is before start' do
    let(:start_at) { 2.days.from_now }
    let(:end_at) { 1.day.from_now }

    it { should be_invalid }
  end

  context 'when end_at is after start' do
    let(:start_at) { 2.days.from_now }
    let(:end_at) { 3.days.from_now }

    it { should be_valid }
  end
end

describe Offer, type: :model do
  describe 'associations' do
    it { should belong_to(:offerer) }
    it { should have_many(:offer_invitations) }
    it { should have_many(:users).through(:offer_invitations) }
  end

  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:place) }
    it { should validate_presence_of(:time_format) }

    describe 'time presence' do
      subject { build(:offer) }

      context 'when time_format is date' do
        before { subject.time_format = :date_format }

        it { should validate_presence_of(:start_at) }
        it { should_not validate_presence_of(:end_at) }
      end

      context 'when time_format is datetime' do
        before { subject.time_format = :datetime_format }

        it { should validate_presence_of(:start_at) }
        it { should_not validate_presence_of(:end_at) }
      end

      context 'when time_format is date_range' do
        before { subject.time_format = :date_range_format }

        it { should validate_presence_of(:start_at) }
        it { should validate_presence_of(:end_at) }
      end

      context 'when time_format is datetime_range' do
        before { subject.time_format = :datetime_range_format }

        it { should validate_presence_of(:start_at) }
        it { should validate_presence_of(:end_at) }
      end
    end

    describe '#start_cannot_be_in_the_past' do
      subject { build(:offer, :details_specified, start_at: start_at) }

      context 'when time_format is date' do
        before { subject.time_format = :date_format }

        context 'when start_at is in the past' do
          let(:start_at) { 1.day.ago }

          it { should be_invalid }
        end

        context 'when start_at is today' do
          let(:start_at) { Time.current.beginning_of_day }

          it { should be_valid }
        end

        context 'when start_at is in the future' do
          let(:start_at) { 1.day.from_now }

          it { should be_valid }
        end
      end

      context 'when time_format is datetime' do
        before { subject.time_format = :datetime_format }

        context 'when start_at is in the past' do
          let(:start_at) { 1.day.ago }

          it { should be_invalid }
        end

        context 'when start_at is today' do
          let(:start_at) { Time.current.beginning_of_day }

          it { should be_invalid }
        end

        context 'when start_at is in the future' do
          let(:start_at) { 1.day.from_now }

          it { should be_valid }
        end
      end
    end

    describe '#end_must_be_after_start' do
      subject do
        build(
          :offer,
          :details_specified,
          start_at: start_at,
          end_at: end_at
        )
      end

      context 'when time_format is date_range' do
        before { subject.time_format = :date_range_format }

        include_examples 'offer end_at validation'

        context 'when end_at is the same as start_at' do
          let(:start_at) { 2.days.from_now }
          let(:end_at) { start_at }

          it { should be_valid }
        end
      end

      context 'when time_format is datetime_range' do
        before { subject.time_format = :datetime_range_format }

        include_examples 'offer end_at validation'

        context 'when end_at is the same as start_at' do
          let(:start_at) { 2.days.from_now }
          let(:end_at) { start_at }

          it { should be_invalid }
        end
      end
    end
  end

  describe 'callbacks' do
    describe '#adjust_end_at' do
      subject { offer.end_at.change(usec: 0) }

      let(:offer) { build(:offer, start_at: start_at, end_at: end_at, time_format: time_format) }

      let(:start_at) { 2.days.from_now }
      let(:end_at) { 3.days.from_now }

      before do
        Timecop.freeze(Time.current)
        offer.save
      end

      after { Timecop.return }

      context 'when time_format is date_format' do
        let(:time_format) { :date_format }

        it { should eq(start_at.end_of_day.change(usec: 0)) }
      end

      context 'when time_format is datetime_format' do
        let(:time_format) { :datetime_format }

        it { should eq(start_at.end_of_day.change(usec: 0)) }

        context 'when end_at is the same as start_at' do
          let(:start_at) { 2.days.from_now.end_of_day }

          it { should eq((start_at + 1.minute).change(usec: 0)) }
        end
      end

      context 'when time_format is date_range_format' do
        let(:time_format) { :date_range_format }

        it { should eq(end_at.end_of_day.change(usec: 0)) }
      end

      context 'when time_format is datetime_range_format' do
        let(:time_format) { :datetime_range_format }

        it { should eq(end_at.change(usec: 0)) }
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
      let(:archived_offer) { build(:offer, :archived, start_at: 2.days.ago, end_at: 1.day.ago) }
      let(:users_invited_offer) { build(:offer, :users_invited, start_at: 2.days.ago, end_at: 1.day.ago) }
      let!(:active_offer) { build(:offer, start_at: 1.day.from_now, end_at: 2.days.from_now) }

      before do
        expired_offer.save(validate: false)
        expired_offer.save(validate: false)
        users_invited_offer.save(validate: false)
      end

      it 'returns published offers with end_at in the past' do
        expect(subject).to include(expired_offer)
        expect(subject).not_to include(archived_offer, users_invited_offer, active_offer)
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

    describe '#archive' do
      subject { offer.archive! }

      let(:offer) { create(:offer, :published) }

      before { create_list(:offer_invitation, 3, :pending, offer: offer) }

      it 'transitions to archived' do
        expect { subject }.to change { offer.reload.aasm_state }
                          .from('published').to('archived')
      end

      it 'expires pending invitations' do
        expect { subject }.to change { offer.reload.offer_invitations.pluck(:aasm_state).uniq }
                          .from(%w[pending]).to(%w[expired])
      end
    end
  end

  describe '#draft?' do
    subject { offer.draft? }

    context 'when offer is in details_specified state' do
      let(:offer) { build(:offer, :details_specified) }

      it { should be_truthy }
    end

    context 'when offer is in users_invited state' do
      let(:offer) { build(:offer, :users_invited) }

      it { should be_truthy }
    end

    context 'when offer is not in details_specified or users_invited state' do
      let(:offer) { build(:offer, :published) }

      it { should be_falsey }
    end
  end

  describe '#publised_or_archived?' do
    subject { offer.published_or_archived? }

    context 'when offer is published' do
      let(:offer) { build(:offer, :published) }

      it { should be_truthy }
    end

    context 'when offer is archived' do
      let(:offer) { build(:offer, :archived) }

      it { should be_truthy }
    end

    context 'when offer is not published nor archived' do
      let(:offer) { build(:offer, :details_specified) }

      it { should be_falsey }
    end
  end

  describe '#expired?' do
    subject { offer.expired? }

    context 'when end_at is in the past for a published offer' do
      let(:offer) { build(:offer, :published, end_at: 1.day.ago) }

      it { should be_truthy }
    end

    context 'when end_at is in the future for a published offer' do
      let(:offer) { build(:offer, :published, end_at: 1.day.from_now) }

      it { should be_falsey }
    end
  end

  describe '#expired_or_archived?' do
    subject { offer.expired_or_archived? }

    context 'when offer is expired' do
      let(:offer) { build(:offer, :published, end_at: 1.day.ago) }

      it { should be_truthy }
    end

    context 'when offer is archived' do
      let(:offer) { build(:offer, :archived) }

      it { should be_truthy }
    end

    context 'when offer is not expired nor archived' do
      let(:offer) { build(:offer, :published, end_at: 1.day.from_now) }

      it { should be_falsey }
    end
  end
end
