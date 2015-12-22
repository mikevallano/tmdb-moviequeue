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
  let(:rating2) { FactoryGirl.create(:rating, user_id: user2.id, movie_id: movie.id) }
  let(:invalid_rating) { FactoryGirl.build(:invalid_rating) }
  let(:valid_attributes) { rating.attributes }
  let(:invalid_attributes) { invalid_rating.attributes }



  shared_examples_for 'logged in access' do
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
          put :update, { :movie_id => movie.id, :id => rating.to_param, :rating => new_attributes }
          rating.reload
          expect(rating.value).to eq(2)
        end

        it "assigns the requested rating as @rating" do
          put :update, { :movie_id => movie.id, :id => rating.to_param, :rating => new_attributes }
          expect(assigns(:rating)).to eq(rating)
        end

        it "redirects to the movie" do
          put :update, { :movie_id => movie.id, :id => rating.to_param, :rating => new_attributes }
          expect(response).to redirect_to(movie_path(movie))
        end
      end

      context "with invalid params" do
        it "assigns the rating as @rating" do
          put :update, { :movie_id => movie.id, :id => rating.to_param, :rating => invalid_attributes }
          expect(assigns(:rating)).to eq(rating)
        end

        it "re-renders the 'edit' template" do
          put :update, { :movie_id => movie.id, :id => rating.to_param, :rating => invalid_attributes }
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

  end #logged in user shared example

  shared_examples_for 'restricted access when not logged in' do
    describe "GET #index" do
      before(:example) do
        get :index, { :movie_id => movie.id }
      end
      it { is_expected.to redirect_to new_user_session_path }
    end

    describe "GET #show" do
      before(:example) do
        get :show, { :movie_id => movie.id, :id => rating.to_param }
      end
        it { is_expected.to redirect_to new_user_session_path }
    end

    describe "GET #new" do
      before(:example) do
        get :new, { :movie_id => movie.id }
      end
     it { is_expected.to redirect_to new_user_session_path }
    end

    describe "GET #edit" do
      before(:example) do
        get :edit, { :movie_id => movie.id, :id => rating.to_param }
      end
     it { is_expected.to redirect_to new_user_session_path }
    end

    describe "POST #create" do
      context "with valid params" do
        before(:example) do
         post :create, { :rating => valid_attributes, movie_id: movie.id }
        end
        it { is_expected.to redirect_to new_user_session_path }
      end

      context "with invalid params" do
        before(:example) do
          post :create, { :rating => invalid_attributes, movie_id: movie.id }
        end
        it { is_expected.to redirect_to new_user_session_path }
      end
    end

    describe "PUT #update" do
      context "with valid params" do
        let(:new_attributes) { FactoryGirl.attributes_for(:rating, value: '5') }

        before(:example) do
          put :update, { :movie_id => movie.id, :id => rating.to_param, :rating => new_attributes }
        end

       it { is_expected.to redirect_to new_user_session_path }
      end

      context "with invalid params" do
        before(:example) do
          put :update, { :movie_id => movie.id, :id => rating.to_param, :rating => invalid_attributes }
        end
        it { is_expected.to redirect_to new_user_session_path }
      end
    end

    describe "DELETE #destroy" do
      before(:example) do
        delete :destroy, { :id => rating.id, movie_id: movie.id }
      end
     it { is_expected.to redirect_to new_user_session_path }
    end

  end #end of user not logged in/shared example

  shared_examples_for 'users can only access their own ratings' do
    describe "GET #index" do
      it "ratings index page shows only current users' ratings" do
        get :index, { :movie_id => movie.id }
        expect(assigns(:ratings)).to eq([rating])
        expect(assigns(:ratings)).not_to include(rating2)
      end
    end

    describe "GET #show" do
      it "it raises an exception if user visits another users review show page" do
        expect {
          get :show, { :movie_id => movie.id, :id => rating2.to_param }
          }.to raise_exception(ActiveRecord::RecordNotFound)
      end
    end

    describe "GET #edit" do
     it "it raises an exception if user visits another users edit review page" do
        expect {
          get :edit, { :movie_id => movie.id, :id => rating2.to_param }
          }.to raise_exception(ActiveRecord::RecordNotFound)
      end
    end

    describe "PUT #update" do
      context "with valid params" do
        let(:new_attributes) { FactoryGirl.attributes_for(:rating, value: '5') }

        it "it raises an exception if user tries to update another users's rating"  do
          expect {
            put :update, { :movie_id => movie.id, :id => rating2.to_param, :rating => new_attributes }
            }.to raise_exception(ActiveRecord::RecordNotFound)
        end
      end

      context "with invalid params" do
        it "it raises an exception if user tries to update another users's rating" do
          expect {
            put :update, { :movie_id => movie.id, :id => rating2.to_param, :rating => invalid_attributes }
            }.to raise_exception(ActiveRecord::RecordNotFound)
        end
      end
    end

    describe "DELETE #destroy" do
     it "it raises an exception if user tries to delete another user's rating" do
        expect {
          delete :destroy, { :id => rating2.id, movie_id: movie.id }
          }.to raise_exception(ActiveRecord::RecordNotFound)
      end
    end

  end #end of user can't access another user's ratings

  describe "user access" do
    before :each do
      current_user
      listing
      rating
    end

    it_behaves_like 'logged in access'
  end

  describe "user not logged in" do
    before(:each) do
      invalid_user
      listing
      rating
    end

    it_behaves_like 'restricted access when not logged in'
  end

  describe "user can't access others' ratings" do
    before(:each) do
      current_user
      rating
      rating2
    end

    it_behaves_like 'users can only access their own ratings'
  end

end #final
