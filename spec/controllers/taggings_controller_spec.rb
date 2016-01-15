require 'rails_helper'

RSpec.describe TaggingsController, type: :controller do

  let(:user) { FactoryGirl.create(:user) }
  let(:current_user) { login_with user }
  let(:invalid_user) { login_with nil }
  let(:movie) { FactoryGirl.create(:movie) }
  let(:tag_list) { "funny, scary" }
  let(:tag) { FactoryGirl.create(:tag) }
  let(:tagging) { FactoryGirl.create(:tagging, tag_id: tag.id, movie_id: movie.id, user_id: user.id) }

  context 'with a logged in user' do

    describe "GET #create" do
      it "creates a new tagging" do
        current_user
        movie
        expect {
          post :create, :tagging => {}, movie_id: movie.id, tag_list: tag_list
        }.to change(Tagging, :count).by(2)
      end

      it "does not create duplicate taggings" do
        current_user
        movie
        expect {
          post :create, :tagging => {}, movie_id: movie.id, tag_list: tag_list
        }.to change(Tagging, :count).by(2)

        expect {
          post :create, :tagging => {}, movie_id: movie.id, tag_list: tag_list
        }.to change(Tagging, :count).by(0)

      end
    end

    describe "DELETE #destroy" do
      it "destroys the requested tagging" do
        current_user
        tagging

        expect {
            delete :destroy, { :tag_id => tagging.tag_id, movie_id: tagging.movie_id }
          }.to change(Tagging, :count).by(-1)
      end

      it "redirects to redirect_url after delete" do
        current_user
        tagging

        delete :destroy, { :tag_id => tagging.tag_id, movie_id: tagging.movie_id }
        expect(response).to redirect_to(movies_url) #redirects to movies_url by default
      end
    end

  end #logged in user scenario

  context 'without a logged in user' do

    describe "POST #create" do
      before(:example) do
        invalid_user
        post :create, :tagging => {}, movie_id: movie.id, tag_list: tag_list
      end
      it { is_expected.to redirect_to new_user_session_path }
    end

    describe "DELETE #destroy" do
      before(:example) do
        invalid_user
        tagging
        delete :destroy, { :tag_id => tagging.tag_id, movie_id: tagging.movie_id }
      end
     it { is_expected.to redirect_to new_user_session_path }
    end

  end #invalid user context

end