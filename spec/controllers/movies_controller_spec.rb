require 'rails_helper'


RSpec.describe MoviesController, type: :controller do


  let(:user) { FactoryGirl.create(:user) }
  let(:current_user) { login_with user }
  let(:invalid_user) { login_with nil }
  let(:movie) { FactoryGirl.create(:movie) }
  let(:list) { FactoryGirl.create(:list, owner_id: user.id) }
  let(:listing) { FactoryGirl.create(:listing, list_id: list.id, movie_id: movie.id) }

  shared_examples_for 'with logged in user' do

    describe "GET #index" do
      it "assigns all movies as @movies" do
        get :index
        expect(assigns(:movies)).to include(movie)
      end
    end

    describe "GET #show" do
      it "assigns the requested movie as @movie" do
        get :show, {:id => movie.to_param}
        expect(assigns(:movie)).to eq(movie)
      end
    end

  end #shared example with logged in user


  shared_examples_for 'without logged in user' do

    describe "GET #index" do
      before(:example) do
        get :index
      end
      it { is_expected.to redirect_to new_user_session_path }
    end

    describe "GET #show" do
      before(:example) do
        movie
        get :show, {:id => movie.to_param}
      end
        it { is_expected.to redirect_to new_user_session_path }
    end

  end #shared example without logged in user

  describe "with logged in user" do
    before :each do
      current_user
      movie
      list
      listing
    end

    it_behaves_like 'with logged in user'
  end

  describe "user not logged in" do
    before :each do
      invalid_user
    end

    it_behaves_like 'without logged in user'
  end

end #final end
