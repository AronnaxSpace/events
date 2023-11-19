describe EndExpiredOffersCronJob do
  subject(:job) { described_class.new.perform }

  before do
    offer = create(:offer, :published, start_at: 2.days.ago)
    offer.end_at = 1.day.ago

    offer.save(validate: false)
  end

  it 'ends expired offers' do
    expect { job }.to change(Offer.ended, :count).from(0).to(1)
  end
end
