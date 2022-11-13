require 'rails_helper'


RSpec.describe ReviewsController, type: :controller do


  let(:user) { FactoryBot.create(:user) }
  let(:user2) { FactoryBot.create(:user) }
  let(:list) { FactoryBot.create(:list, :owner => user) }
  let(:list2) { FactoryBot.create(:list, :owner => user2) }
  let(:movie)  { FactoryBot.create(:movie) }
  let(:movie1)  { FactoryBot.create(:movie) }
  let(:movie2)  { FactoryBot.create(:movie) }
  let(:movie3) { FactoryBot.create(:movie) }
  let(:current_user) { login_with user }
  let(:current_user2) { login_with user2 }
  let(:invalid_user) { login_with nil }
  let(:listing) { FactoryBot.create(:listing, list_id: list.id, movie_id: movie.id) }
  let(:listing2) { FactoryBot.create(:listing, list_id: list.id, movie_id: movie2.id) }
  let(:listing3) { FactoryBot.create(:listing, list_id: list.id, movie_id: movie3.id) }
  let(:review) { FactoryBot.create(:review, user_id: user.id, movie_id: movie.id) }
  let(:review2) { FactoryBot.create(:review, user_id: user2.id, movie_id: movie.id) }
  let(:invalid_review) { FactoryBot.build(:invalid_review) }
  let(:valid_attributes) { review.attributes }
  let(:invalid_attributes) { invalid_review.attributes }


  shared_examples_for 'logged in access' do
    describe "GET #index" do
      it "assigns all reviews as @reviews" do
        get :index, params: { :movie_id => movie.id }
        expect(assigns(:reviews)).to eq([review])
      end
    end

    describe "GET #show" do
      it "assigns the requested review as @review" do
        get :show, params: { :movie_id => movie.id, :id => review.to_param }
        expect(assigns(:review)).to eq(review)
      end
    end

    describe "GET #new" do
      it "assigns a new review as @review" do
        list2
        get :new, params: { :movie_id => movie2.id }
        expect(assigns(:review)).to be_a_new(Review)
      end
    end

    describe "GET #edit" do
      it "assigns the requested review as @review" do
        get :edit, params: { :movie_id => movie.id, :id => review.to_param }
        expect(assigns(:review)).to eq(review)
      end
    end

    describe "POST #create" do
      context "with valid params" do
        it "creates a new Review" do
          expect {
            post :create, params: { :review => valid_attributes, movie_id: movie.id }
          }.to change(Review, :count).by(1)
        end

        it "assigns a newly created review as @review" do
          post :create, params: { :review => { user_id: user.id, movie_id: movie2.id, body: "the jam" }, movie_id: movie2.id }
          expect(assigns(:review)).to be_a(Review)
          expect(assigns(:review)).to be_persisted
        end

        it "redirects to the movie" do
          post :create, params: { :review => { user_id: user.id, movie_id: movie3.id, body: "the jammer" }, movie_id: movie3.id }
          expect(response).to redirect_to(movie_url(movie3))
        end
      end

      context "with invalid params" do
        it "assigns a newly created but unsaved review as @review" do
          post :create, params: { :review => invalid_attributes, movie_id: movie.id }
          expect(assigns(:review)).to be_a_new(Review)
        end

        it "re-renders the 'new' template" do
          post :create, params: { :review => invalid_attributes, movie_id: movie.id }
          expect(response).to render_template("new")
        end
      end
    end

    describe "PUT #update" do
      context "with valid params" do
        let(:new_attributes) { FactoryBot.attributes_for(:review, body: "epic movie!") }

        it "updates the requested review" do
          put :update, params: { :movie_id => movie.id, :id => review.to_param, :review => new_attributes }
          review.reload
          expect(review.body).to eq("epic movie!")
        end

        it "assigns the requested review as @review" do
          put :update, params: { :movie_id => movie.id, :id => review.to_param, :review => valid_attributes }
          expect(assigns(:review)).to eq(review)
        end

        it "redirects to the movie" do
          put :update, params: { :movie_id => movie.id, :id => review.to_param, :review => valid_attributes }
          expect(response).to redirect_to(movie_path(movie))
        end
      end

      context "with invalid params" do
        it "assigns the review as @review" do
          put :update, params: { :movie_id => movie.id, :id => review.to_param, :review => invalid_attributes }
          expect(assigns(:review)).to eq(review)
        end

        it "re-renders the 'edit' template" do
          put :update, params: { :movie_id => movie.id, :id => review.to_param, :review => invalid_attributes }
          expect(response).to render_template("edit")
        end
      end
    end

    describe "DELETE #destroy" do
      it "destroys the requested review" do
        review
        expect {
          delete :destroy, params: { :id => review.id, movie_id: movie.id }
        }.to change(Review, :count).by(-1)
      end

      it "redirects to the movie" do
        delete :destroy, params: { :id => review.to_param, movie_id: movie.id }
        expect(response).to redirect_to(movie_url(movie))
      end
    end

  end #logged in user shared example

  shared_examples_for 'restricted access when not logged in' do
    describe "GET #index" do
      before(:example) do
        get :index, params: { :movie_id => movie.id }
      end
      it { is_expected.to redirect_to new_user_session_path }
    end

    describe "GET #show" do
      before(:example) do
        get :show, params: { :movie_id => movie.id, :id => review.to_param }
      end
        it { is_expected.to redirect_to new_user_session_path }
    end

    describe "GET #new" do
      before(:example) do
        get :new, params: { :movie_id => movie.id }
      end
     it { is_expected.to redirect_to new_user_session_path }
    end

    describe "GET #edit" do
      before(:example) do
        get :edit, params: { :movie_id => movie.id, :id => review.to_param }
      end
     it { is_expected.to redirect_to new_user_session_path }
    end

    describe "POST #create" do
      context "with valid params" do
        before(:example) do
         post :create, params: { :review => valid_attributes, movie_id: movie.id }
        end
        it { is_expected.to redirect_to new_user_session_path }
      end

      context "with invalid params" do
        before(:example) do
          post :create, params: { :review => invalid_attributes, movie_id: movie.id }
        end
        it { is_expected.to redirect_to new_user_session_path }
      end
    end

    describe "PUT #update" do
      context "with valid params" do
        let(:new_attributes) { FactoryBot.attributes_for(:review, value: '5') }

        before(:example) do
          put :update, params: { :movie_id => movie.id, :id => review.to_param, :review => new_attributes }
        end

       it { is_expected.to redirect_to new_user_session_path }
      end

      context "with invalid params" do
        before(:example) do
          put :update, params: { :movie_id => movie.id, :id => review.to_param, :review => invalid_attributes }
        end
        it { is_expected.to redirect_to new_user_session_path }
      end
    end

    describe "DELETE #destroy" do
      before(:example) do
        delete :destroy, params: { :id => review.id, movie_id: movie.id }
      end
     it { is_expected.to redirect_to new_user_session_path }
    end

  end #end of user not logged in/shared example

  shared_examples_for 'users can only access their own reviews' do
    describe "GET #index" do
      it "ratings index page shows all users' reviews" do
        get :index, params: { :movie_id => movie.id }
        expect(assigns(:reviews)).to include(review2)
      end
    end

    describe "GET #show" do
      before(:example) do
        get :show, params: { :movie_id => movie.id, :id => review2.to_param }
      end
     it { is_expected.to redirect_to(movie_path(movie))}
    end

    describe "GET #edit" do
      before(:example) do
        get :edit, params: { :movie_id => movie.id, :id => review2.to_param }
      end
     it { is_expected.to redirect_to(movie_path(movie))}
    end

    describe "PUT #update" do
      context "with valid params" do
        let(:new_attributes) { FactoryBot.attributes_for(:review, body: 'it was teh bestest') }
        before(:example) do
          put :update, params: { :movie_id => movie.id, :id => review2.to_param, :rating => new_attributes }
        end
       it { is_expected.to redirect_to(movie_path(movie))}
      end

      context "with invalid params" do
        before(:example) do
          put :update, params: { :movie_id => movie.id, :id => review2.to_param, :rating => invalid_attributes }
        end
       it { is_expected.to redirect_to(movie_path(movie))}
      end
    end

    describe "DELETE #destroy" do
      before(:example) do
        delete :destroy, params: { :id => review2.id, movie_id: movie.id }
      end
      it { is_expected.to redirect_to(movie_path(movie))}
    end

  end #end of user can't access another user's reviews

  describe "user access" do
    before :each do
      current_user
      listing
    end

    it_behaves_like 'logged in access'
  end

  describe "user not logged in" do
    before(:each) do
      invalid_user
      listing
      review
    end

    it_behaves_like 'restricted access when not logged in'
  end

  describe "user can't access others' reviews" do
    before(:each) do
      current_user
      review
      review2
    end

    it_behaves_like 'users can only access their own reviews'
  end

end #final
