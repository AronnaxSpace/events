shared_examples 'event end_at validation' do
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

describe Event, type: :model do
  describe 'associations' do
    it { should belong_to(:owner) }
    it { should have_many(:event_invitations) }
    it { should have_many(:users).through(:event_invitations) }
  end

  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:place) }
    it { should validate_presence_of(:time_format) }

    describe 'time presence' do
      subject { build(:event) }

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
      subject { build(:event, :details_specified, start_at: start_at) }

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
          :event,
          :details_specified,
          start_at: start_at,
          end_at: end_at
        )
      end

      context 'when time_format is date_range' do
        before { subject.time_format = :date_range_format }

        include_examples 'event end_at validation'

        context 'when end_at is the same as start_at' do
          let(:start_at) { 2.days.from_now }
          let(:end_at) { start_at }

          it { should be_valid }
        end
      end

      context 'when time_format is datetime_range' do
        before { subject.time_format = :datetime_range_format }

        include_examples 'event end_at validation'

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
      subject { event.end_at.change(usec: 0) }

      let(:event) { build(:event, start_at: start_at, end_at: end_at, time_format: time_format) }

      let(:start_at) { 2.days.from_now }
      let(:end_at) { 3.days.from_now }

      before do
        Timecop.freeze(Time.current)
        event.save
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
      let!(:event_created_by_user) { create(:event, owner: user) }
      let(:event_with_pending_invitation) { create(:event) }
      let(:event_with_accepted_invitation) { create(:event) }
      let(:event_with_declined_invitation) { create(:event) }
      let!(:event_without_invitation) { create(:event) }

      before do
        create(:event_invitation, :pending, event: event_with_pending_invitation, user: user)
        create(:event_invitation, :accepted, event: event_with_accepted_invitation, user: user)
        create(:event_invitation, :declined, event: event_with_declined_invitation, user: user)
      end

      it 'returns events for a given user' do
        expect(subject).to include(
          event_created_by_user,
          event_with_pending_invitation,
          event_with_accepted_invitation
        )
        expect(subject).not_to include(event_without_invitation)
        expect(subject).not_to include(event_with_declined_invitation)
      end
    end

    describe '.expired' do
      subject { described_class.expired }

      let(:expired_event) { build(:event, :published, start_at: 2.days.ago, end_at: 1.day.ago) }
      let(:archived_event) { build(:event, :archived, start_at: 2.days.ago, end_at: 1.day.ago) }
      let(:users_invited_event) { build(:event, :users_invited, start_at: 2.days.ago, end_at: 1.day.ago) }
      let!(:active_event) { build(:event, start_at: 1.day.from_now, end_at: 2.days.from_now) }

      before do
        expired_event.save(validate: false)
        expired_event.save(validate: false)
        users_invited_event.save(validate: false)
      end

      it 'returns published events with end_at in the past' do
        expect(subject).to include(expired_event)
        expect(subject).not_to include(archived_event, users_invited_event, active_event)
      end
    end
  end

  describe 'aasm_state transitions' do
    describe '#invite_users' do
      subject { event.invite_users }

      let(:event) { create(:event, :details_specified) }

      it 'transitions to users_invited' do
        expect { subject }.to change { event.aasm_state }.from('details_specified').to('users_invited')
      end
    end

    describe '#publish' do
      subject { event.publish! }

      let(:event) { create(:event, :users_invited) }

      before { create_list(:event_invitation, 3, :draft, event: event) }

      it 'transitions to publish' do
        expect { subject }.to change { event.reload.aasm_state }
                          .from('users_invited').to('published')
      end

      it 'sends invitations' do
        expect { subject }.to change { event.reload.event_invitations.pluck(:aasm_state).uniq }
                          .from(%w[draft]).to(%w[pending])
      end
    end

    describe '#archive' do
      subject { event.archive! }

      let(:event) { create(:event, :published) }

      before { create_list(:event_invitation, 3, :pending, event: event) }

      it 'transitions to archived' do
        expect { subject }.to change { event.reload.aasm_state }
                          .from('published').to('archived')
      end

      it 'expires pending invitations' do
        expect { subject }.to change { event.reload.event_invitations.pluck(:aasm_state).uniq }
                          .from(%w[pending]).to(%w[expired])
      end
    end
  end

  describe '#draft?' do
    subject { event.draft? }

    context 'when event is in details_specified state' do
      let(:event) { build(:event, :details_specified) }

      it { should be_truthy }
    end

    context 'when event is in users_invited state' do
      let(:event) { build(:event, :users_invited) }

      it { should be_truthy }
    end

    context 'when event is not in details_specified or users_invited state' do
      let(:event) { build(:event, :published) }

      it { should be_falsey }
    end
  end

  describe '#publised_or_archived?' do
    subject { event.published_or_archived? }

    context 'when event is published' do
      let(:event) { build(:event, :published) }

      it { should be_truthy }
    end

    context 'when event is archived' do
      let(:event) { build(:event, :archived) }

      it { should be_truthy }
    end

    context 'when event is not published nor archived' do
      let(:event) { build(:event, :details_specified) }

      it { should be_falsey }
    end
  end

  describe '#expired?' do
    subject { event.expired? }

    context 'when end_at is in the past for a published event' do
      let(:event) { build(:event, :published, end_at: 1.day.ago) }

      it { should be_truthy }
    end

    context 'when end_at is in the future for a published event' do
      let(:event) { build(:event, :published, end_at: 1.day.from_now) }

      it { should be_falsey }
    end
  end

  describe '#expired_or_archived?' do
    subject { event.expired_or_archived? }

    context 'when event is expired' do
      let(:event) { build(:event, :published, end_at: 1.day.ago) }

      it { should be_truthy }
    end

    context 'when event is archived' do
      let(:event) { build(:event, :archived) }

      it { should be_truthy }
    end

    context 'when event is not expired nor archived' do
      let(:event) { build(:event, :published, end_at: 1.day.from_now) }

      it { should be_falsey }
    end
  end
end
