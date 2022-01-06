require 'rails_helper'


RSpec.describe ScreeningsController, type: :controller do


  let(:user) { FactoryBot.create(:user) }
  let(:user2) { FactoryBot.create(:user) }
  let(:list) { FactoryBot.create(:list, :owner => user) }
  let(:list2) { FactoryBot.create(:list, :owner => user2) }
  let(:movie)  { FactoryBot.create(:movie) }
  let(:current_user) { login_with user }
  let(:current_user2) { login_with user2 }
  let(:invalid_user) { login_with nil }
  let(:listing) { FactoryBot.create(:listing, list_id: list.id, movie_id: movie.id) }
  let(:screening) { FactoryBot.create(:screening, user_id: user.id, movie_id: movie.id) }
  let(:screening2) { FactoryBot.create(:screening, user_id: user2.id, movie_id: movie.id) }
  let(:invalid_screening) { FactoryBot.build(:invalid_screening) }
  let(:valid_attributes) { screening.attributes }
  let(:invalid_attributes) { invalid_screening.attributes }



  shared_examples_for 'logged in access' do
    describe "GET #index" do
      it "assigns all screenings as @screenings" do
        get :index, { :movie_id => movie.id }
        expect(assigns(:screenings)).to eq([screening])
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

        it "redirects to screenings index" do
          post :create, { :screening => valid_attributes, movie_id: movie.id }
          expect(response).to redirect_to(movie_screenings_path(movie))
        end
      end

      context "with invalid params" do
        it "if no movie_id is passed, it raises an error" do
          expect {
          post :create, { :screening => invalid_attributes, movie_id: nil }
          }.to raise_error
        end
      end
    end

    describe "PUT #update" do
      context "with valid params" do
        let(:new_attributes) { FactoryBot.attributes_for(:screening, notes: "epic notes!") }

        it "updates the requested screening" do
          put :update, { :movie_id => movie.id, :id => screening.to_param, :screening => new_attributes }
          screening.reload
          expect(screening.notes).to eq("epic notes!")
        end

        it "assigns the requested screening as @screening" do
          put :update, { :movie_id => movie.id, :id => screening.to_param, :screening => valid_attributes }
          expect(assigns(:screening)).to eq(screening)
        end

        it "redirects to screenings index" do
          put :update, { :movie_id => movie.id, :id => screening.to_param, :screening => valid_attributes }
          expect(response).to redirect_to(movie_screenings_path(movie))
        end
      end

      context "with invalid params" do
        it "assigns the screening as @screening" do
          put :update, { :movie_id => movie.id, :id => screening.to_param, :screening => invalid_attributes }
          expect(assigns(:screening)).to eq(screening)
        end
      end
    end

    describe "DELETE #destroy" do
      it "destroys the requested screening" do
        expect {
          delete :destroy, { :id => screening.id, movie_id: movie.id }
        }.to change(Screening, :count).by(-1)
      end

      it "redirects to screenings index" do
        delete :destroy, { :id => screening.to_param, movie_id: movie.id }
        expect(response).to redirect_to(movie_screenings_path(movie))
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

    describe "GET #new" do
      before(:example) do
        get :new, { :movie_id => movie.id }
      end
     it { is_expected.to redirect_to new_user_session_path }
    end

    describe "GET #edit" do
      before(:example) do
        get :edit, { :movie_id => movie.id, :id => screening.to_param }
      end
     it { is_expected.to redirect_to new_user_session_path }
    end

    describe "POST #create" do
      context "with valid params" do
        before(:example) do
         post :create, { :screening => valid_attributes, movie_id: movie.id }
        end
        it { is_expected.to redirect_to new_user_session_path }
      end

      context "with invalid params" do
        before(:example) do
          post :create, { :screening => invalid_attributes, movie_id: movie.id }
        end
        it { is_expected.to redirect_to new_user_session_path }
      end
    end

    describe "PUT #update" do
      context "with valid params" do
        let(:new_attributes) { FactoryBot.attributes_for(:screening, notes: "epic notes!") }

        before(:example) do
          put :update, { :movie_id => movie.id, :id => screening.to_param, :screening => new_attributes }
        end

       it { is_expected.to redirect_to new_user_session_path }
      end

      context "with invalid params" do
        before(:example) do
          put :update, { :movie_id => movie.id, :id => screening.to_param, :screening => invalid_attributes }
        end
        it { is_expected.to redirect_to new_user_session_path }
      end
    end

    describe "DELETE #destroy" do
      before(:example) do
        delete :destroy, { :id => screening.id, movie_id: movie.id }
      end
     it { is_expected.to redirect_to new_user_session_path }
    end

  end #end of user not logged in/shared example

  shared_examples_for 'users can only access their own screenings' do
    describe "GET #index" do
      it "screenings index page shows only current users' screenings" do
        get :index, { :movie_id => movie.id }
        expect(assigns(:screenings)).to eq([screening])
        expect(assigns(:screenings)).not_to include(screening2)
      end
    end

    describe "GET #edit" do
     it "it raises an exception if user visits another users edit review page" do
        expect {
          get :edit, { :movie_id => movie.id, :id => screening2.to_param }
          }.to raise_exception(ActiveRecord::RecordNotFound)
      end
    end

    describe "PUT #update" do
      context "with valid params" do
        let(:new_attributes) { FactoryBot.attributes_for(:screening, notes: "epic notes!") }

        it "it raises an exception if user tries to update another users's screening"  do
          expect {
            put :update, { :movie_id => movie.id, :id => screening2.to_param, :screening => new_attributes }
            }.to raise_exception(ActiveRecord::RecordNotFound)
        end
      end

      context "with invalid params" do
        it "it raises an exception if user tries to update another users's screening" do
          expect {
            put :update, { :movie_id => movie.id, :id => screening2.to_param, :screening => invalid_attributes }
            }.to raise_exception(ActiveRecord::RecordNotFound)
        end
      end
    end

    describe "DELETE #destroy" do
     it "it raises an exception if user tries to delete another user's screening" do
        expect {
          delete :destroy, { :id => screening2.id, movie_id: movie.id }
          }.to raise_exception(ActiveRecord::RecordNotFound)
      end
    end

  end #end of user can't access another user's screenings

  describe "user access" do
    before :each do
      current_user
      listing
      screening
    end

    it_behaves_like 'logged in access'
  end

  describe "user not logged in" do
    before(:each) do
      invalid_user
      listing
      screening
    end

    it_behaves_like 'restricted access when not logged in'
  end

  describe "user can't access others' screenings" do
    before(:each) do
      current_user
      screening
      screening2
    end

    it_behaves_like 'users can only access their own screenings'
  end

end #final
