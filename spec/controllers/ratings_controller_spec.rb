require 'rails_helper'


RSpec.describe RatingsController, type: :controller do


  let(:user) { FactoryGirl.create(:user) }
  let(:user2) { FactoryGirl.create(:user) }
  let(:list) { FactoryGirl.create(:list, :owner => user) }
  let(:list2) { FactoryGirl.create(:list, :owner => user2) }
  let(:movie)  { FactoryGirl.create(:movie) }
  let(:current_user) { login_with user }
  let(:current_user2) { login_with user2 }
  let(:invalid_user) { login_with nil }
  let(:listing) { FactoryGirl.create(:listing, list_id: list.id, movie_id: movie.id) }
  let(:rating) { FactoryGirl.create(:rating, user_id: user.id, movie_id: movie.id) }
  let(:invalid_rating) { FactoryGirl.build(:invalid_rating) }
  let(:valid_attributes) { rating.attributes }
  let(:invalid_attributes) { invalid_rating.attributes }


  before(:each) do
    movie
    user
    list
    listing
    rating
    current_user
  end


  describe "GET #index" do
    it "assigns all ratings as @ratings" do
      get :index, { :movie_id => movie.id }
      expect(assigns(:ratings)).to eq([rating])
    end
  end

  describe "GET #show" do
    it "assigns the requested rating as @rating" do
      get :show, { :movie_id => movie.id, :id => rating.to_param }
      expect(assigns(:rating)).to eq(rating)
    end
  end

  describe "GET #new" do
    it "assigns a new rating as @rating" do
      get :new, { :movie_id => movie.id }
      expect(assigns(:rating)).to be_a_new(Rating)
    end
  end

  describe "GET #edit" do
    it "assigns the requested rating as @rating" do
      get :edit, { :movie_id => movie.id, :id => rating.to_param }
      expect(assigns(:rating)).to eq(rating)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Rating" do
        expect {
          post :create, { :rating => valid_attributes, movie_id: movie.id }
        }.to change(Rating, :count).by(1)
      end

      it "assigns a newly created rating as @rating" do
        post :create, { :rating => valid_attributes, movie_id: movie.id }
        expect(assigns(:rating)).to be_a(Rating)
        expect(assigns(:rating)).to be_persisted
      end

      it "redirects to the movie" do
        post :create, { :rating => valid_attributes, movie_id: movie.id }
        expect(response).to redirect_to(movie_url(movie))
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved rating as @rating" do
        post :create, { :rating => invalid_attributes, movie_id: movie.id }
        expect(assigns(:rating)).to be_a_new(Rating)
      end

      it "re-renders the 'new' template" do
        post :create, { :rating => invalid_attributes, movie_id: movie.id }
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) { FactoryGirl.attributes_for(:rating, value: "2") }

      it "updates the requested rating" do
        put :update, { :movie_id => movie.id, :id => rating.to_param, :rating => new_attributes}
        rating.reload
        expect(rating.value).to eq(2)
      end

      it "assigns the requested rating as @rating" do
        put :update, { :movie_id => movie.id, :id => rating.to_param, :rating => valid_attributes}
        expect(assigns(:rating)).to eq(rating)
      end

      it "redirects to the movie" do
        put :update, { :movie_id => movie.id, :id => rating.to_param, :rating => valid_attributes}
        expect(response).to redirect_to(movie_path(movie))
      end
    end

    context "with invalid params" do
      it "assigns the rating as @rating" do
        put :update, { :movie_id => movie.id, :id => rating.to_param, :rating => invalid_attributes}
        expect(assigns(:rating)).to eq(rating)
      end

      it "re-renders the 'edit' template" do
        put :update, { :movie_id => movie.id, :id => rating.to_param, :rating => invalid_attributes}
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested rating" do
      expect {
        delete :destroy, { :id => rating.id, movie_id: movie.id }
      }.to change(Rating, :count).by(-1)
    end

    it "redirects to the movie" do
      delete :destroy, { :id => rating.to_param, movie_id: movie.id }
      expect(response).to redirect_to(movie_url(movie))
    end
  end

end
