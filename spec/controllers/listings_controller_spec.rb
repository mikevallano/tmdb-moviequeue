require 'rails_helper'

RSpec.describe ListingsController, type: :controller do

  let(:movie) { FactoryGirl.create(:movie) }
  let(:tmdb_id) { movie.tmdb_id }
  let(:valid_attributes) { {tmdb_id: tmdb_id} }
  let(:listing) { FactoryGirl.create(:listing) }


  describe "GET #create" do
    it "creates a new listing" do
      movie
      tmdb_id
      expect {
        post :create, :listing => { movie_id: movie.id }, tmdb_id: tmdb_id
      }.to change(Listing, :count).by(1)
    end
  end

  describe "GET #destroy" do
    it "destroys the requested listing" do
      listing
      skip "need to figure this out"
      expect {
          delete :destroy, delete_listing_path("#{listing.list_id}", "#{listing.movie_id}")
        }.to change(Listing, :count).by(-1)
      end
  end


end
