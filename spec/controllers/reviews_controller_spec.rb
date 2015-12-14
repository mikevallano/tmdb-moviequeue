require 'rails_helper'


RSpec.describe ReviewsController, type: :controller do


  let(:user) { FactoryGirl.create(:user) }
  let(:user2) { FactoryGirl.create(:user) }
  let(:list) { FactoryGirl.create(:list, :owner => user) }
  let(:list2) { FactoryGirl.create(:list, :owner => user2) }
  let(:movie)  { FactoryGirl.create(:movie) }
  let(:current_user) { login_with user }
  let(:current_user2) { login_with user2 }
  let(:invalid_user) { login_with nil }
  let(:listing) { FactoryGirl.create(:listing, list_id: list.id, movie_id: movie.id) }
  let(:review) { FactoryGirl.create(:review, user_id: user.id, movie_id: movie.id) }
  let(:invalid_review) { FactoryGirl.build(:invalid_review) }
  let(:valid_attributes) { review.attributes }
  let(:invalid_attributes) { invalid_review.attributes }
  let(:valid_session) {}


  before(:each) do
    movie
    user
    list
    listing
    review
    current_user
  end


  describe "GET #index" do
    it "assigns all reviews as @reviews" do
      get :index, { :movie_id => movie.id }
      expect(assigns(:reviews)).to eq([review])
    end
  end

  describe "GET #show" do
    it "assigns the requested review as @review" do
      get :show, { :movie_id => movie.id, :id => review.to_param }
      expect(assigns(:review)).to eq(review)
    end
  end

  describe "GET #new" do
    it "assigns a new review as @review" do
      get :new, { :movie_id => movie.id }
      expect(assigns(:review)).to be_a_new(Review)
    end
  end

  describe "GET #edit" do
    it "assigns the requested review as @review" do
      get :edit, { :movie_id => movie.id, :id => review.to_param }
      expect(assigns(:review)).to eq(review)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Review" do
        expect {
          post :create, { :review => valid_attributes, movie_id: movie.id }
        }.to change(Review, :count).by(1)
      end

      it "assigns a newly created review as @review" do
        post :create, { :review => valid_attributes, movie_id: movie.id }
        expect(assigns(:review)).to be_a(Review)
        expect(assigns(:review)).to be_persisted
      end

      it "redirects to the movie" do
        post :create, { :review => valid_attributes, movie_id: movie.id }
        expect(response).to redirect_to(movie_url(movie))
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved review as @review" do
        post :create, { :review => invalid_attributes, movie_id: movie.id }
        expect(assigns(:review)).to be_a_new(Review)
      end

      it "re-renders the 'new' template" do
        post :create, { :review => invalid_attributes, movie_id: movie.id }
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) { FactoryGirl.attributes_for(:review, body: "epic movie!") }

      it "updates the requested review" do
        put :update, { :movie_id => movie.id, :id => review.to_param, :review => new_attributes}
        review.reload
        expect(review.body).to eq("epic movie!")
      end

      it "assigns the requested review as @review" do
        put :update, { :movie_id => movie.id, :id => review.to_param, :review => valid_attributes}
        expect(assigns(:review)).to eq(review)
      end

      it "redirects to the movie" do
        put :update, { :movie_id => movie.id, :id => review.to_param, :review => valid_attributes}
        expect(response).to redirect_to(movie_path(movie))
      end
    end

    context "with invalid params" do
      it "assigns the review as @review" do
        put :update, { :movie_id => movie.id, :id => review.to_param, :review => invalid_attributes}
        expect(assigns(:review)).to eq(review)
      end

      it "re-renders the 'edit' template" do
        put :update, { :movie_id => movie.id, :id => review.to_param, :review => invalid_attributes}
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested review" do
      expect {
        delete :destroy, { :id => review.id, movie_id: movie.id }
      }.to change(Review, :count).by(-1)
    end

    it "redirects to the movie" do
      delete :destroy, { :id => review.to_param, movie_id: movie.id }
      expect(response).to redirect_to(movie_url(movie))
    end
  end

end
