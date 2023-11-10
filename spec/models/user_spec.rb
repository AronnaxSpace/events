require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { should have_many(:offer_invitations) }
    it { should have_many(:offers).through(:offer_invitations) }
  end
end
