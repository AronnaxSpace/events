describe OffersHelper do
  describe '#offer_time' do
    subject { helper.offer_time_for(offer) }

    let(:offer) { build(:offer) }

    it { should eq("#{offer.start_at} - #{offer.end_at}") }
  end

  describe '#offer_state_tag_classes_for' do
    subject { helper.offer_state_tag_classes_for(offer) }

    context 'when offer is in one of draft states' do
      let(:offer) { build(:offer, :users_invited) }

      it { should eq('tag-warning') }
    end

    context 'when offer is archived' do
      let(:offer) { build(:offer, :archived) }

      it { should eq('tag-secondary') }
    end

    context 'when offer is published' do
      let(:offer) { build(:offer) }

      it { should eq('tag-success') }
    end
  end
end
