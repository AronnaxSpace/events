describe EndExpiredOffersCronJob do
  subject(:job) { described_class.new.perform }

  before { create(:offer, :expired) }

  it 'ends expired offers' do
    expect { job }.to change(Offer.ended, :count).from(0).to(1)
  end
end
