require 'rails_helper'

RSpec.describe TaggingsController, type: :controller do

  let(:tagging) { FactoryGirl.create(:tagging) }


  describe "GET #create" do
    it "creates a new tagging" do
      skip "skip until controller is implemented"
      movie
      tmdb_id
      expect {
        post :create, :tagging => { movie_id: movie.id }, tmdb_id: tmdb_id
      }.to change(Tagging, :count).by(1)
    end
  end

  describe "GET #destroy" do
    it "destroys the requested tagging" do
      skip "skip until controller is implemented"
      expect {
          delete :destroy, delete_tagging_path("#{tagging.list_id}", "#{tagging.movie_id}")
        }.to change(Tagging, :count).by(-1)
      end
  end


end