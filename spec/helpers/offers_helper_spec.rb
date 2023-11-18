describe OffersHelper do
  describe '#offer_time' do
    subject { helper.offer_time_for(offer) }

    let(:offer) { build(:offer) }

    it { should eq("#{offer.start_at} - #{offer.end_at}") }
  end
end
