require 'rails_helper'

RSpec.describe 'Offers', type: :request do
  include_context 'logged in user'

  describe 'GET /index' do
    before { get '/offers' }

    it 'gets HTTP status 200' do
      expect(response.status).to eq 200
    end
  end
end
