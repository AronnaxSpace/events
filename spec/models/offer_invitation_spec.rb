require 'rails_helper'

RSpec.describe OfferInvitation, type: :model do
  describe 'associations' do
    it { should belong_to(:offer) }
    it { should belong_to(:user) }
  end
end
