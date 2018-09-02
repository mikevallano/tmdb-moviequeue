require 'rails_helper'

RSpec.describe TaggingsController, type: :controller do

  let(:user) { FactoryBot.create(:user) }
  let(:current_user) { login_with user }
  let(:invalid_user) { login_with nil }
  let(:movie) { FactoryBot.create(:movie) }
  let(:tag_list) { "funny, scary" }
  let(:tag) { FactoryBot.create(:tag) }
  let(:tagging) { FactoryBot.create(:tagging, tag_id: tag.id, movie_id: movie.id, user_id: user.id) }

  context 'with a logged in user' do

    describe "GET #create" do
      it "creates a new tagging" do
        current_user
        movie
        expect {
          post :create, tagging: {}, movie_id: movie.id, tag_list: tag_list
        }.to change(Tagging, :count).by(2)
      end

      it "does not create duplicate taggings" do
        current_user
        movie
        expect {
          post :create, tagging: {}, movie_id: movie.id, tag_list: tag_list
        }.to change(Tagging, :count).by(2)

        expect {
          post :create, tagging: {}, movie_id: movie.id, tag_list: tag_list
        }.to change(Tagging, :count).by(0)

      end

      it "redirects to movie by default" do
        current_user
        movie
        post :create, tagging: {}, movie_id: movie.id, tag_list: tag_list

        expect(response).to redirect_to(movie_path(movie)) #redirects to movie by default
      end
    end

    describe "DELETE #destroy" do
      it "destroys the requested tagging" do
        current_user
        tagging

        expect {
            delete :destroy, { tag_id: tagging.tag_id, movie_id: tagging.movie_id, format: :js }
          }.to change(Tagging, :count).by(-1)
      end

      it "handles missing tagging" do
        current_user
        tagging

        delete :destroy, { tag_id: 0, movie_id: tagging.movie_id, format: :js }
        expect(assigns(:error)).to be_present
      end
    end

  end #logged in user scenario

  context 'without a logged in user' do

    describe "POST #create" do
      before(:example) do
        invalid_user
        post :create, tagging: {}, movie_id: movie.id, tag_list: tag_list
      end
      it { is_expected.to redirect_to new_user_session_path }
    end

    describe "DELETE #destroy" do
      before(:example) do
        invalid_user
        tagging
        delete :destroy, { tag_id: tagging.tag_id, movie_id: tagging.movie_id }
      end
     it { is_expected.to redirect_to new_user_session_path }
    end

  end #invalid user context

end
