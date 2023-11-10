require 'rails_helper'

RSpec.describe Offer, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:what) }

    describe 'when_start or when_text cannot both be nil' do
      let(:offer) { build(:offer, when_start: nil, when_text: nil) }

      it 'is not valid' do
        expect(offer).to_not be_valid
        expect(offer.errors[:base]).to include('Offer date must be present')
      end
    end
  end
end
