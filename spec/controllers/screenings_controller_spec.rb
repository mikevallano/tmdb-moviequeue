require 'rails_helper'


RSpec.describe ScreeningsController, type: :controller do


  let(:user) { FactoryGirl.create(:user) }
  let(:user2) { FactoryGirl.create(:user) }
  let(:list) { FactoryGirl.create(:list, :owner => user) }
  let(:list2) { FactoryGirl.create(:list, :owner => user2) }
  let(:movie)  { FactoryGirl.create(:movie) }
  let(:current_user) { login_with user }
  let(:current_user2) { login_with user2 }
  let(:invalid_user) { login_with nil }
  let(:listing) { FactoryGirl.create(:listing, list_id: list.id, movie_id: movie.id) }
  let(:screening) { FactoryGirl.create(:screening, user_id: user.id, movie_id: movie.id) }
  let(:invalid_screening) { FactoryGirl.build(:invalid_screening) }
  let(:valid_attributes) { screening.attributes }
  let(:invalid_attributes) { invalid_screening.attributes }
  let(:valid_session) {}


  before(:each) do
    movie
    user
    list
    listing
    screening
    current_user
  end


  describe "GET #index" do
    it "assigns all screenings as @screenings" do
      get :index, { :movie_id => movie.id }
      expect(assigns(:screenings)).to eq([screening])
    end
  end

  describe "GET #show" do
    it "assigns the requested screening as @screening" do
      get :show, { :movie_id => movie.id, :id => screening.to_param }
      expect(assigns(:screening)).to eq(screening)
    end
  end

  describe "GET #new" do
    it "assigns a new screening as @screening" do
      get :new, { :movie_id => movie.id }
      expect(assigns(:screening)).to be_a_new(Screening)
    end
  end

  describe "GET #edit" do
    it "assigns the requested screening as @screening" do
      get :edit, { :movie_id => movie.id, :id => screening.to_param }
      expect(assigns(:screening)).to eq(screening)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Screening" do
        expect {
          post :create, { :screening => valid_attributes, movie_id: movie.id }
        }.to change(Screening, :count).by(1)
      end

      it "assigns a newly created screening as @screening" do
        post :create, { :screening => valid_attributes, movie_id: movie.id }
        expect(assigns(:screening)).to be_a(Screening)
        expect(assigns(:screening)).to be_persisted
      end

      it "redirects to the movie" do
        post :create, { :screening => valid_attributes, movie_id: movie.id }
        expect(response).to redirect_to(movie_url(movie))
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved screening as @screening" do
        post :create, { :screening => invalid_attributes, movie_id: movie.id }
        expect(assigns(:screening)).to be_a_new(Screening)
      end

      it "re-renders the 'new' template" do
        post :create, { :screening => invalid_attributes, movie_id: movie.id }
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) { FactoryGirl.attributes_for(:screening, notes: "epic notes!") }

      it "updates the requested screening" do
        put :update, { :movie_id => movie.id, :id => screening.to_param, :screening => new_attributes}
        screening.reload
        expect(screening.notes).to eq("epic notes!")
      end

      it "assigns the requested screening as @screening" do
        put :update, { :movie_id => movie.id, :id => screening.to_param, :screening => valid_attributes}
        expect(assigns(:screening)).to eq(screening)
      end

      it "redirects to the movie" do
        put :update, { :movie_id => movie.id, :id => screening.to_param, :screening => valid_attributes}
        expect(response).to redirect_to(movie_path(movie))
      end
    end

    context "with invalid params" do
      it "assigns the screening as @screening" do
        put :update, { :movie_id => movie.id, :id => screening.to_param, :screening => invalid_attributes}
        expect(assigns(:screening)).to eq(screening)
      end

      it "re-renders the 'edit' template" do
        put :update, { :movie_id => movie.id, :id => screening.to_param, :screening => invalid_attributes}
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested screening" do
      expect {
        delete :destroy, { :id => screening.id, movie_id: movie.id }
      }.to change(Screening, :count).by(-1)
    end

    it "redirects to the movie" do
      delete :destroy, { :id => screening.to_param, movie_id: movie.id }
      expect(response).to redirect_to(movie_url(movie))
    end
  end

end
