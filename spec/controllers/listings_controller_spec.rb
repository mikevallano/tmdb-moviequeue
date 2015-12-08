require 'rails_helper'

RSpec.describe ListingsController, type: :controller do

  let(:movie) { FactoryGirl.create(:movie) }
  let(:tmdb_id) { movie.tmdb_id }
  let(:valid_attributes) { {tmdb_id: tmdb_id} }


  describe "GET #create" do
    it "creates a new listing" do
      skip "trying to get this figured out"
      movie
      tmdb_id
      poster = post :create, :listing => {tmdb_id: tmdb_id, movie_id: movie.id}
      expect {
        post :create, :listing => {tmdb_id: tmdb_id}
      }.to change(Listing, :count).by(1)
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
