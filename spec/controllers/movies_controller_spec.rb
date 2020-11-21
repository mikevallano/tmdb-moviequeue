require 'rails_helper'

RSpec.describe MoviesController, type: :controller do

  let(:user) { create(:user) }
  let(:admin_user) { create(:user, admin: true) }
  let(:current_user) { login_with user }
  let(:invalid_user) { login_with nil }
  let(:movie) { create(:movie) }
  let(:list) { create(:list, owner_id: user.id) }
  let(:listing) { create(:listing, list_id: list.id, movie_id: movie.id) }
  let(:youtube_id) { '44urisjfk' }

  shared_examples_for 'with logged in user' do

    describe "GET #index" do
      it "assigns all movies as @movies" do
        get :index
        expect(assigns(:movies)).to include(movie)
      end
    end

    describe "GET #show" do
      it "assigns the requested movie as @movie" do
        get :show, {id: movie.to_param}
        expect(assigns(:movie)).to eq(movie)
      end
    end

    describe 'PATCH #update' do
      context 'with an admin' do
        let(:current_user) { login_with(admin_user) }
        it 'updates the movie' do
          patch :update,
                { id: movie.id,
                  tmdb_id: movie.tmdb_id,
                  trailer: youtube_id }
          expect(movie.reload.trailer).to eq(youtube_id)
        end

        it 'strips full youtube url' do
          patch :update,
                { id: movie.id,
                  tmdb_id: movie.tmdb_id,
                  trailer: "https://www.youtube.com/watch?v=#{youtube_id}" }
          expect(movie.reload.trailer).to eq(youtube_id)
        end

        it 'strips youtube url with additional params' do
          patch :update,
                { id: movie.id,
                  tmdb_id: movie.tmdb_id,
                  trailer: "https://www.youtube.com/watch?v=#{youtube_id}&ab_channel=A24" }
          expect(movie.reload.trailer).to eq(youtube_id)
        end

        it 'redirects to the movie show page, trailer-section' do
          patch :update,
                { id: movie.id,
                  tmdb_id: movie.tmdb_id,
                  trailer: "https://www.youtube.com/watch?v=#{youtube_id}" }
          expect(response).to redirect_to(movie_path(movie, anchor: 'trailer-section'))
        end

        context 'with invalid or non-youtube trailers' do
          # TODO: This illustrates how it currently works.
          # In https://github.com/mikevallano/tmdb-moviequeue/issues/218,
          # the plan is to restrict the form field to valid youtube urls,
          # only allow admins access to this feature,
          # or add a new join table so random users can't modify movies directly.
          it 'leaves non-youtube urls as-is' do
            trailer = 'https://www.example.com'
            patch :update,
                  { id: movie.id,
                    tmdb_id: movie.tmdb_id,
                    trailer: trailer }
            expect(movie.reload.trailer).to eq(trailer)
          end

          it 'handles empty trailer urls' do
            trailer = ''
            patch :update,
                  { id: movie.id,
                    tmdb_id: movie.tmdb_id,
                    trailer: trailer }
            expect(movie.reload.trailer).to eq(trailer)
          end
        end
      end

      context 'with a non-admin' do
        let(:current_user) { login_with(user) }
        it 'does not update the movie' do
          @request.env['HTTP_REFERER'] = movie_path(movie)
          patch :update,
                  { id: movie.id,
                    tmdb_id: movie.tmdb_id,
                    trailer: youtube_id }
            expect(movie.reload.trailer).not_to eq(youtube_id)
            expect(response).to redirect_to(movie_path(movie))
            expect(flash[:alert]).to eq('Must be an admin to access that feature')
        end
      end
    end # describe #update

  end #shared example with logged in user


  shared_examples_for 'without logged in user' do

    describe "GET #index" do
      before(:example) do
        get :index
      end
      it { is_expected.to redirect_to new_user_session_path }
    end

    describe "GET #show" do
      before(:example) do
        movie
        get :show, {id: movie.to_param}
      end
        it { is_expected.to redirect_to new_user_session_path }
    end

  end #shared example without logged in user

  describe "with logged in user" do
    before :each do
      current_user
      movie
      list
      listing
    end

    it_behaves_like 'with logged in user'
  end

  describe "user not logged in" do
    before :each do
      invalid_user
    end

    it_behaves_like 'without logged in user'
  end

end #final end
