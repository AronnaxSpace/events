describe EventPolicy do
  subject { described_class }

  let(:owner) { create(:user) }
  let(:event) { build(:event, owner: owner) }

  permissions :manage?, :destroy? do
    it 'denies access if user is not an owner' do
      expect(subject).not_to permit(create(:user), event)
    end

    it 'grants access if user is an owner' do
      expect(subject).to permit(owner, event)
    end
  end

  permissions :edit?, :update? do
    context 'when the event is not archived' do
      let(:event) { build(:event, :published, owner: owner) }

      it 'denies access if user is not an owner' do
        expect(subject).not_to permit(create(:user), event)
      end

      it 'grants access if user is an owner' do
        expect(subject).to permit(owner, event)
      end
    end

    context 'when the event is archived' do
      let(:event) { build(:event, :archived, owner: owner) }

      it 'denies access' do
        expect(subject).not_to permit(create(:user), event)
      end
    end
  end
end
