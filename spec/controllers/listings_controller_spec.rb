require 'rails_helper'

RSpec.describe ListingsController, type: :controller do

  describe "GET #create" do
    it "returns http success" do
      skip "skip until the listings functionality is sorted out"
      get :create
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #destroy" do
    it "returns http success" do
      skip "skip until the listings functionality is sorted out"
      get :destroy
      expect(response).to have_http_status(:success)
    end
  end

end
