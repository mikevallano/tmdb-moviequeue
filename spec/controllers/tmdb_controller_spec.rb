require 'rails_helper'

RSpec.describe TmdbController, type: :controller do

  let(:user) { FactoryBot.create(:user) }
  let(:current_user) { login_with user }
  let(:invalid_user) { login_with nil }
  let(:movie) { FactoryBot.create(:movie) }

  context 'with a logged in user' do

    describe "GET #search" do
      it "returns http success" do
        current_user
        get :search
        expect(response).to have_http_status(:success)
      end
    end

    describe "GET #actor_search" do
      it "returns http success" do
        current_user
        get :actor_search
        expect(response).to have_http_status(:success)
      end
    end

    describe "GET #two_actor_search" do
      it "returns http success" do
        current_user
        get :two_actor_search
        expect(response).to have_http_status(:success)
      end
    end

    describe "GET #more" do
      it "searches the tmdb api and returns an http success" do
        current_user
        VCR.use_cassette('tmdb_controller_more') do
          get :movie_more, params: { tmdb_id: 275 }
        end
        expect(response).to have_http_status(:success)
      end

      it "redirects the user back to search page with if no movie_id is passed" do
        current_user
        get :movie_more
        expect(response).to have_http_status(:redirect)
      end
    end

  end #logged in user context

  context 'without a logged in user' do

    describe "GET #search" do
      before(:example) do
        invalid_user
        get :search
      end
      it { is_expected.to redirect_to new_user_session_path }
    end

    describe "GET #actor_search" do
      before(:example) do
        invalid_user
        get :actor_search
      end
      it { is_expected.to redirect_to new_user_session_path }
    end

    describe "GET #two_actor_search" do
      before(:example) do
        invalid_user
        get :two_actor_search
      end
      it { is_expected.to redirect_to new_user_session_path }
    end

    describe "GET #more" do
      before(:example) do
        invalid_user
        VCR.use_cassette('tmdb_controller_more') do
          get :movie_more, params: { movie_id: 275 }
        end
      end
      it { is_expected.to redirect_to new_user_session_path }
    end

  end

end
