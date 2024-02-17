describe EventsHelper do
  describe '#event_time' do
    subject { helper.event_time_for(event) }

    let(:event) { build(:event) }

    it { should eq("#{event.start_at} - #{event.end_at}") }
  end

  describe '#event_state_tag_classes_for' do
    subject { helper.event_state_tag_classes_for(event) }

    context 'when event is in one of draft states' do
      let(:event) { build(:event, :users_invited) }

      it { should eq('tag-warning') }
    end

    context 'when event is archived' do
      let(:event) { build(:event, :archived) }

      it { should eq('tag-secondary') }
    end

    context 'when event is published' do
      let(:event) { build(:event) }

      it { should eq('tag-success') }
    end
  end
end
