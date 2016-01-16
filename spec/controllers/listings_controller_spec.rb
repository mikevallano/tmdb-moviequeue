require 'rails_helper'

RSpec.describe ListingsController, type: :controller do

  let(:user) { FactoryGirl.create(:user) }
  let(:current_user) { login_with user }
  let(:invalid_user) { login_with nil }
  let(:movie) { FactoryGirl.create(:movie) }
  let(:list) { FactoryGirl.create(:list, owner_id: user.id) }
  let(:tmdb_id) { movie.tmdb_id }
  let(:valid_attributes) { {tmdb_id: tmdb_id} }
  let(:listing) { FactoryGirl.create(:listing, movie_id: movie.id, list_id: list.id) }


  shared_examples_for 'logged in access' do

    describe "GET #create" do
      it "creates a new listing" do
        expect {
          post :create, :listing => { movie_id: movie.id, list_id: list.id }, tmdb_id: tmdb_id, user_id: user.id
        }.to change(Listing, :count).by(1)
      end
    end

    describe "PUT #update" do
      it "updates the priority" do
        put :update, { :list_id => listing.list_id, movie_id: listing.movie_id, priority: '1'}
        listing.reload
        expect(listing.priority).to eq(1)
      end
    end

    describe "GET #destroy" do
      it "destroys the requested listing" do
        expect {
            delete :destroy, { :list_id => listing.list_id, movie_id: listing.movie_id }
          }.to change(Listing, :count).by(-1)
      end

      it "redirects to movies path after deleting" do
        delete :destroy, { :list_id => listing.list_id, movie_id: listing.movie_id }
        expect(response).to redirect_to(user_list_path(listing.list.owner, listing.list))
      end
    end

  end #shared example for logged in user

  shared_examples_for 'restricted access when not logged in' do

    describe "POST #create" do
      context "with valid params" do
        before(:example) do
         post :create, :listing => { movie_id: movie.id }, tmdb_id: tmdb_id
        end
        it { is_expected.to redirect_to new_user_session_path }
      end

      context "with invalid params" do
        before(:example) do
          post :create, :listing => { movie_id: nil }, tmdb_id: nil
        end
        it { is_expected.to redirect_to new_user_session_path }
      end
    end

    describe "PUT #update" do
      before(:example) do
        put :update, { :list_id => listing.list_id, movie_id: listing.movie_id, priority: '1'}
      end

     it { is_expected.to redirect_to new_user_session_path }
    end

    describe "DELETE #destroy" do
      before(:example) do
        delete :destroy, { :list_id => listing.list_id, movie_id: listing.movie_id }
      end
     it { is_expected.to redirect_to new_user_session_path }
    end

  end #end of user not logged in/shared example

  describe "user access" do
    before :each do
      user
      current_user
      listing
      list
      movie
      tmdb_id
    end

    it_behaves_like 'logged in access'
  end

  describe "user not logged in" do
    before(:each) do
      invalid_user
      listing
      list
      movie
      tmdb_id
    end

    it_behaves_like 'restricted access when not logged in'
  end


end #final
