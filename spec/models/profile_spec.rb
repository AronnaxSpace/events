require 'rails_helper'

RSpec.describe Profile, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:nickname) }

    context 'uniqueness of nickname' do
      subject { FactoryBot.create(:profile) }

      it { should validate_uniqueness_of(:nickname).case_insensitive }
    end
  end
end
