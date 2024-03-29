require 'rails_helper'

RSpec.describe ListsController, type: :controller do

  let(:list_name) { SecureRandom.urlsafe_base64(10) }
  let(:user) { FactoryBot.create(:user) }
  let(:user2) { FactoryBot.create(:user) }
  let(:list) { FactoryBot.create(:list, :owner => user) }
  let(:list2) { FactoryBot.create(:list, :owner => user2) }
  let(:public_list) { FactoryBot.create(:list, :owner => user, :is_public => true) }
  let(:invalid_list) { FactoryBot.create(:invalid_list) }
  let(:current_user) { login_with user }
  let(:current_user2) { login_with user2 }
  let(:invalid_user) { login_with nil }
  let(:valid_attributes) { {name: list_name, owner_id: user.id} }
  let(:invalid_attributes) { {name: nil} }

  shared_examples_for 'logged in access to lists' do
    describe "GET #index" do
      it "assigns all lists as @lists" do
        get :index, params: { user_id: user.to_param }
        expect(assigns(:lists)).to eq([list])
      end

      it "renders the index template" do
        get :index, params: { user_id: user.to_param }
        expect(response).to render_template(:index)
      end
    end

    describe "GET #public" do
      before(:each) do
        public_list
        current_user2
      end
      it "assigns all public lists as @lists" do
        get :public
        expect(assigns(:lists)).to eq([public_list])
      end

      it "renders the public template" do
        get :public
        expect(response).to render_template(:public)
      end
    end

    describe "GET #show" do
      it "assigns the requested list as @list" do
        get :show, params: { :id => list.to_param, user_id: user.to_param }
        expect(assigns(:list)).to eq(list)
      end

    end

    describe "GET #new" do
      it "assigns a new list as @list" do
        get :new, params: { user_id: user.to_param }
        expect(assigns(:list)).to be_a_new(List)
      end

      it "renders the new template" do
        get :new, params: { user_id: user.to_param }
        expect(response).to render_template(:new)
      end
    end

    describe "GET #edit" do
      it "assigns the requested list as @list" do
        get :edit, params: { :id => list.to_param, user_id: user.to_param }
        expect(assigns(:list)).to eq(list)
      end

      it "renders the edit template" do
        get :edit, params: { :id => list.to_param, user_id: user.to_param }
        expect(response).to render_template(:edit)
      end
    end

    describe "POST #create" do
      context "with valid params" do
        it "creates a new List" do
          expect {
            post :create, params: { :list => valid_attributes, user_id: user.to_param }
          }.to change(List, :count).by(1)
        end

        it "assigns a newly created list as @list" do
          post :create, params: { :list => valid_attributes, user_id: user.to_param }
          expect(assigns(:list)).to be_a(List)
          expect(assigns(:list)).to be_persisted
        end

        it "redirects to the created list" do
          post :create, params: { :list => valid_attributes, user_id: user.to_param }
          expect(response).to redirect_to(user_lists_path(user))
        end

      end

      context "with invalid params" do
        it "assigns a newly created but unsaved list as @list" do
          post :create, params: { :list => invalid_attributes, user_id: user.to_param }
          expect(assigns(:list)).to be_a_new(List)
        end

        it "re-renders the 'new' template" do
          post :create, params: { :list => invalid_attributes, user_id: user.to_param }
          expect(response).to render_template("new")
        end
      end
    end

    describe "PUT #update" do
      context "with valid params" do
        let(:new_attributes) { FactoryBot.attributes_for(:list, name: "zibbler") }

        it "updates the requested list" do
          put :update, params: { user_id: user.to_param, :id => list.to_param, :list => new_attributes }
          list.reload
          expect(list.name).to eq("zibbler")
        end

        it "assigns the requested list as @list" do
          put :update, params: { user_id: user.to_param, :id => list.to_param, :list => new_attributes }
          expect(assigns(:list)).to eq(list)
        end

        it "redirects to the list" do
          put :update, params: { user_id: user.to_param, :id => list.to_param, :list => new_attributes }
          expect(response).to redirect_to(user_lists_path(user))
        end
      end

      context "with invalid params" do
        it "assigns the list as @list" do
          put :update, params: { user_id: user.to_param, :id => list.to_param, :list => invalid_attributes }
          expect(assigns(:list)).to eq(list)
        end

        it "re-renders the 'edit' template" do
          put :update, params: { user_id: user.to_param, :id => list.to_param, :list => invalid_attributes }
          expect(response).to render_template("edit")
        end
      end
    end

    describe "DELETE #destroy" do
      it "destroys the requested list" do
        expect {
          delete :destroy, params: { :id => list.to_param, user_id: user.to_param }
        }.to change(List, :count).by(-1)
      end

      it "redirects to the lists list" do
        delete :destroy, params: { :id => list.to_param, user_id: user.to_param }
        expect(response).to redirect_to(user_lists_url(user))
      end
    end
  end #end of user logged in/shared example

  shared_examples_for 'restricted access when not logged in' do
    describe "GET #index" do
      before(:example) do
        get :index, params: { user_id: user.to_param }
      end
      it { is_expected.to redirect_to new_user_session_path }
    end

    describe "GET #show" do
      before(:example) do
        get :show, params: { :id => list.to_param, user_id: user.to_param }
      end
        it { is_expected.to redirect_to new_user_session_path }
    end

    describe "GET #new" do
      before(:example) do
        get :new, params: { user_id: user.to_param }
      end
     it { is_expected.to redirect_to new_user_session_path }
    end

    describe "GET #edit" do
      before(:example) do
        get :edit, params: { user_id: user.to_param, :id => list.to_param}
      end
     it { is_expected.to redirect_to new_user_session_path }
    end

    describe "POST #create" do
      context "with valid params" do
        before(:example) do
         post :create, params: { :list => valid_attributes, user_id: user.to_param }
        end
        it { is_expected.to redirect_to new_user_session_path }
      end

      context "with invalid params" do
        before(:example) do
          post :create, params: { :list => invalid_attributes, user_id: user.to_param }
        end
        it { is_expected.to redirect_to new_user_session_path }
      end
    end

    describe "PUT #update" do
      context "with valid params" do
        let(:new_attributes) { FactoryBot.attributes_for(:list, name: "zibbler", description: "zag nuts") }

        before(:example) do
          put :update, params: { user_id: user.to_param, :id => list.to_param, :list => new_attributes }
        end

       it { is_expected.to redirect_to new_user_session_path }
      end

      context "with invalid params" do
        before(:example) do
          put :update, params: { user_id: user.to_param, :id => list.to_param, :list => FactoryBot.attributes_for(:invalid_list)}
        end
        it { is_expected.to redirect_to new_user_session_path }
      end
    end

    describe "DELETE #destroy" do

      before(:example) do
        delete :destroy, params: { :id => list.to_param, user_id: user.to_param }
      end
     it { is_expected.to redirect_to new_user_session_path }
    end

  end #end of user not logged in/shared example

  shared_examples_for 'users can only access their own lists' do
    describe "GET #index" do
      it "assigns all lists as @lists" do
        get :index, params: { user_id: user2.to_param }
        expect(assigns(:lists)).to eq([list])
        expect(assigns(:lists)).not_to include(list2)
      end
    end

    # TODO: remove in https://github.com/mikevallano/tmdb-moviequeue/issues/403
    xdescribe "GET #show when the list is public" do

      it "shows the public_show template if current_user.all_lists doesn't include list" do
        public_list
        current_user2
        get :show, params: { :id => public_list.to_param, :user_id => user.to_param }
        expect(response).to render_template(:public_show)
      end

      it "renders the show template if current_user.all_lists does include list" do
        public_list
        current_user
        get :show, params: { :id => public_list.to_param, :user_id => user.to_param }
        expect(response).to render_template(:show)
      end
    end

    describe "GET #show" do
      before(:example) do
        get :show, params: { :id => list2.to_param, user_id: user2.to_param }
      end
        it { is_expected.to redirect_to user_lists_path(user) }
    end

    describe "GET #edit" do
      before(:example) do
        get :edit, params: { :id => list2.to_param, user_id: user2.to_param }
      end
     it { is_expected.to redirect_to user_lists_path(user) }
    end

    describe "PUT #update" do
      context "with valid params" do
        let(:new_attributes) { FactoryBot.attributes_for(:list, name: "zibbler") }

        before(:example) do
          put :update, params: { user_id: user2.to_param, :id => list2.to_param, :list => new_attributes }
        end

       it { is_expected.to redirect_to user_lists_path(user) }
      end

      context "with invalid params" do
        before(:example) do
          put :update, params: { user_id: user2.to_param, :id => list2.to_param, :list => FactoryBot.attributes_for(:invalid_list) }
        end
        it { is_expected.to redirect_to user_lists_path(user) }
      end
    end

    describe "DELETE #destroy" do

      before(:example) do
        delete :destroy, params: { user_id: user2.to_param, :id => list2.to_param }
      end
     it { is_expected.to redirect_to user_lists_path(user) }
    end

  end #end of user can't access another user's lists


  describe "user access" do
    before :each do
      current_user
      list
    end

    it_behaves_like 'logged in access to lists'
  end

  describe "user not logged in" do
    before(:each) do
      invalid_user
      list
    end

    it_behaves_like 'restricted access when not logged in'
  end

  describe "user can't access others' lists" do
    before(:each) do
      current_user
      list
      list2
    end

    it_behaves_like 'users can only access their own lists'
  end

end #final ender
