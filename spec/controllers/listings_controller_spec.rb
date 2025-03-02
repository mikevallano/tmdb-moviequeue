require 'rails_helper'

RSpec.describe ListingsController, type: :controller do

  let(:user) { FactoryBot.create(:user) }
  let(:user2) { FactoryBot.create(:user) }
  let(:current_user) { login_with user }
  let(:current_user2) { login_with user2 }
  let(:invalid_user) { login_with nil }
  let(:movie) { FactoryBot.create(:movie) }
  let(:movie2) { FactoryBot.create(:movie) }
  let(:list) { FactoryBot.create(:list, owner_id: user.id) }
  let(:tmdb_id) { movie.tmdb_id }
  let(:tmdb_id2) { movie2.tmdb_id }
  let(:valid_attributes) { {tmdb_id: tmdb_id} }
  let(:listing) { FactoryBot.create(:listing, movie_id: movie.id, list_id: list.id, user_id: user.id) }


  shared_examples_for "logged in access" do

    describe "GET #create" do
      it "creates a new listing" do
        expect {
          post :create, params: { listing: { movie_id: movie2.id, list_id: list.id, user_id: user.id }, tmdb_id: tmdb_id2 }
        }.to change(Listing, :count).by(1)
      end
    end

    describe "PUT #update" do
      it "updates the priority" do
        put :update, params: { :list_id => listing.list_id, movie_id: listing.movie_id, priority: 4}
        listing.reload
        expect(listing.priority).to eq(4)
      end
    end

    describe "GET #destroy" do
      it "destroys the requested listing" do
        expect {
            delete :destroy, params: { :list_id => listing.list_id, movie_id: listing.movie_id }
          }.to change(Listing, :count).by(-1)
      end

      it "redirects to movies path after deleting" do
        delete :destroy, params: { :list_id => listing.list_id, movie_id: listing.movie_id }
        expect(response).to redirect_to(user_list_path(listing.list.owner, listing.list))
      end
    end

  end #shared example for logged in user

  shared_examples_for "restricted access when not logged in" do

    describe "POST #create" do
      context "with valid params" do
        before(:example) do
         post :create, params: { listing: { movie_id: movie.id }, tmdb_id: tmdb_id }
        end
        it { is_expected.to redirect_to new_user_session_path }
      end

      context "with invalid params" do
        before(:example) do
          post :create, params: { listing: { movie_id: nil }, tmdb_id: nil }
        end
        it { is_expected.to redirect_to new_user_session_path }
      end
    end

    describe "PUT #update" do
      before(:example) do
        put :update, params: { :list_id => listing.list_id, movie_id: listing.movie_id, priority: 4}
      end

     it { is_expected.to redirect_to new_user_session_path }
    end

    describe "DELETE #destroy" do
      before(:example) do
        delete :destroy, params: { :list_id => listing.list_id, movie_id: listing.movie_id }
      end
     it { is_expected.to redirect_to new_user_session_path }
    end

  end #end of user not logged in/shared example

  shared_examples_for "does not let a user update or delete another users listing" do

    it "doesn't let a user update another user's listing" do
      put :update, params: { :list_id => listing.list_id, movie_id: listing.movie_id, priority: 4}
      expect(response).to redirect_to(user_lists_path(user2))
      listing.reload
      expect(listing.priority).not_to eq(4)
    end

    it "doesn't let a user destroy another user's listing" do
      expect {
          delete :destroy, params: { :list_id => listing.list_id, movie_id: listing.movie_id }
        }.to change(Listing, :count).by(0)
    end

    it "redirects the wrong user trying to update another user's listing" do
      delete :destroy, params: { :list_id => listing.list_id, movie_id: listing.movie_id }
      expect(response).to redirect_to(user_lists_path(user2))
    end

  end #shared examples for does not let a user update or delete another users listing

  describe "user access" do
    before :each do
      user
      current_user
      listing
      list
      movie
      tmdb_id
    end

    it_behaves_like "logged in access"
  end

  describe "user not logged in" do
    before(:each) do
      invalid_user
      listing
      list
      movie
      tmdb_id
    end

    it_behaves_like "restricted access when not logged in"
  end

  describe "users can not update or destroy other users listings" do
    before(:each) do
        current_user2
        listing
        list
        movie
        tmdb_id
      end
    it_behaves_like "does not let a user update or delete another users listing"
  end


end #final
