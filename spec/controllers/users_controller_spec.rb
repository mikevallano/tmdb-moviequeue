require 'rails_helper'

RSpec.describe UsersController, type: :controller do

  let(:user) { FactoryBot.create(:user) }
  let(:user2) { FactoryBot.create(:user) }
  let(:current_user) { login_with user }
  let(:current_user2) { login_with user2 }
  let(:invalid_user) { login_with nil }

  context 'with a logged-in user' do
    before(:each) do
      current_user
    end

    describe "GET #show" do
      it "returns http success" do
        get :show, { :id => user.to_param }
        expect(response).to have_http_status(:success)
      end
    end

    describe "Users can't access other users' profile page" do
      before(:example) do
        current_user2
        get :show, { :id => user.to_param }
      end
      it { is_expected.to redirect_to root_path }
    end

  end #with logged-in user context

  context 'without a logged-in user' do

    before(:each) do
      user
      invalid_user
    end

    describe "GET #show" do
      before(:example) do
        get :show, { :id => user.to_param }
      end
        it { is_expected.to redirect_to new_user_session_path }
    end

  end #without logged-in user

end #final
