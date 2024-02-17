describe EndExpiredEventsCronJob do
  subject(:job) { described_class.new.perform }

  before do
    event = build(:event, :published, start_at: 2.days.ago)
    event.end_at = 1.day.ago

    event.save(validate: false)
  end

  it 'ends expired events' do
    expect { job }.to change(Event.archived, :count).from(0).to(1)
  end
end
