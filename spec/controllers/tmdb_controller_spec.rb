require 'rails_helper'

RSpec.describe TmdbController, type: :controller do

  describe "GET #search" do
    it "returns http success" do
      get :search
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #more" do
    it "returns http success" do
      get :more
      expect(response).to have_http_status(:success)
    end
  end

end
