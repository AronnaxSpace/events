require 'rails_helper'

RSpec.describe 'Offers', type: :request do
  include_context 'logged in user'

  describe 'GET /index' do
    before { get offers_path }

    it 'gets HTTP status 200' do
      expect(response.status).to eq 200
    end
  end

  describe 'GET /show' do
    let!(:offer) { create(:offer, owner: user) }

    before { get offer_path(offer) }

    it 'gets HTTP status 200' do
      expect(response.status).to eq 200
    end
  end

  describe 'GET /new' do
    before { get new_offer_path }

    it 'gets HTTP status 200' do
      expect(response.status).to eq 200
    end
  end

  describe 'GET /edit' do
    let!(:offer) { create(:offer, owner: user) }

    before { get edit_offer_path(offer) }

    it 'gets HTTP status 200' do
      expect(response.status).to eq 200
    end
  end

  describe 'POST /create' do
    subject { post offers_path, params: { offer: attributes_for(:offer) } }

    it 'creates a new offer' do
      expect { subject }.to change(Offer, :count).by(1)
    end
  end

  describe 'PATCH /update' do
    let!(:offer) { create(:offer, owner: user) }
    let(:params) { { offer: attributes_for(:offer) } }

    before { patch offer_path(offer), params: params }

    it 'updates the offer' do
      expect(offer.reload).to have_attributes(params[:offer])
    end
  end

  describe 'DELETE /destroy' do
    let!(:offer) { create(:offer, owner: user) }

    subject { delete offer_path(offer) }

    it 'deletes the offer' do
      expect { subject }.to change(Offer, :count).by(-1)
    end
  end
end
